# frozen_string_literal: true

module V1
  class TweetsController < ApiController
    before_action :set_api_token

    def create
      # TODO: check weather location in OpenWeatherMap and change the input text
      input_location = params[:location].to_s.strip

      if @api_token.nil? || @api_token.expired? || input_location.empty?
        return head :unprocessable_entity
      end

      tweet_response = new_tweet_with_text(input_location)

      if tweet_response.status.eql?(200)
        input = {
          user_id: @api_token.user.id,
          api_token_event_id: @api_token.id,
          uid: tweet_response.body['data']['id'],
          text: tweet_response.body['data']['text']
        }

        Tweet
          .new(input)
          .then do |tweet|
            render json: { data: { tweet: { text: tweet.text } } }, status: :ok if tweet.save!
          end
      end
    end

    private

    def set_api_token
      @api_token = ApiTokenEvent.find_by(token: params[:token])
    end

    def new_tweet_with_text(text)
      Clients::Twitter::V2::Tweets::ManageTweets
        .new(oauth_token: @api_token.access_token)
        .new_tweet(text)
    end
  end
end
