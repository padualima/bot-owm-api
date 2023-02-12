# frozen_string_literal: true

module V1
  class TweetsController < ApiController
    before_action :set_api_token

    def create
      # TODO: IMPROVE CLAUSE GUARDE WITH VALIDATE PARAMS(LAT, LON AND NAME)
      if tweet_params.empty? || tweet_params.values.map(&:empty?).any? ||
          @api_token.nil? || @api_token.expired?
        return head :unprocessable_entity
      end

      fetch_location
        .then { |lat, lon| current_weather_for(lat:, lon:) }
        .then do |current_weather|
          case current_weather.status
          in 200; weather_static_text_builder(body: current_weather.body)
          else
            # TODO: RETURN MESSAGE ERROR FOR API_OPEN_WEATHER CALL ERROR
          end
        end
        .then { |text| create_tweet_with_text(text) }
        .then do |tweet_response|
          case tweet_response.status
          in 200
            Tweet
              .new(
                user_id: @api_token.user.id,
                api_token_event_id: @api_token.id,
                uid: tweet_response.body['data']['id'],
                text: tweet_response.body['data']['text']
              )
              .then do |tweet|
                render_json({ data: { tweets: { text: tweet.text } } }, :ok) if tweet.save!
              end
          else
            # TODO: RETURN MESSAGE ERROR FOR TWITTER CALL ERROR
          end
        end
    end

    private

    def set_api_token
      @api_token = ApiTokenEvent.find_by(token: params[:token])
    end

    def tweet_params
      params.require(:location).permit(:lat, :lon, :name)
    end

    def fetch_location
      if tweet_params.include?(:lat) && tweet_params.include?(:lon)
        tweet_params.then { |param| [param[:lat].to_f, param[:lon].to_f] }
      elsif tweet_params.include?(:name)
        Geocoder.search(tweet_params[:name])[0].coordinates
      end
    end

    def weather_static_text_builder(body:)
      # TODO: CHANGE THIS TO A TEXT CREATION SERVICE
      body['coord'].values
    end

    def current_weather_for(lat:, lon:)
      Clients::OpenWeatherMap::V3::Weather.current(lat: lat, lon: lon)
    end

    def create_tweet_with_text(text)
      Clients::Twitter::V2::Tweets::ManageTweets
        .new(oauth_token: @api_token.access_token)
        .new_tweet(text)
    end
  end
end
