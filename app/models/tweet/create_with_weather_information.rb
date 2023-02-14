# frozen_string_literal: true

class Tweet::CreateWithWeatherInformation < ::Micro::Case
  attribute :lat
  attribute :lon
  attribute :location_name, default: -> value { value.to_s.strip }
  attribute :api_token, default: -> value { value if value.is_a?(ApiTokenEvent) }

  def call!
    validate_location_attributes
      .then(apply(:fetch_location))
      .then(apply(:get_weather_information))
      .then(apply(:weather_static_text_builder))
      .then(apply(:publish_tweet))
      .then(apply(:perform_creation))
  end

  private

  def validate_location_attributes
    errors = {}

    unless lat && lon || location_name.present?
      errors[:location_missing] = "params location is missing"
    else
      if lat && lon
        errors[:lat] = "latitude is not valid" unless latitude_is_valid?(lat)
        errors[:lon] = "longitude is not valid" unless latitude_is_valid?(lon)
      elsif fetch_location_name(location_name).empty?
        errors[:location_name] = "location name not found"
      end
    end

    return Success(:valid_params) if errors.blank?

    Failure(:invalid_params, result: { message: ErrorSerializer.new(errors.values, 422) })
  end

  def fetch_location(lat:, lon:, location_name:, **)
    lat, lon = fetch_location_name(location_name)[0].coordinates if location_name.present?

    Success result: { lat: lat, lon: lon }
  end

  def get_weather_information(lat:, lon:, **)
    Success result: { current_weather: OpenWeatherMap::CurrentWeatherInformation.call(lat:, lon:) }
  end

  def weather_static_text_builder(current_weather:, **)
    Success result: { text: WeatherStaticTextBuilder.call(current_weather) }
  end

  def publish_tweet(api_token:, text:, **)
    access_token = api_token.access_token
    Success result: { tweet_published: Twitter::PublishTweet.call(access_token:, text:) }
  end

  def perform_creation(api_token:, tweet_published:, **)
    input = {
      user_id: api_token.user.id,
      api_token_event_id: api_token.id,
      uid: tweet_published['data']['id'],
      text: tweet_published['data']['text']
    }

    tweet = Tweet.create(input)

    return Success :tweet_create, result: { tweet: tweet } if tweet.id?

    Failure :tweet_invalid, result: { message: tweet.errors.full_messages }
  end

  def latitude_is_valid?(lat)
    return false unless lat.to_s =~ /^-?([1-8]?\d(?:\.\d{1,})?|90(?:\.0{1,6})?)$/
    true
  end

  def longitude_is_valid?(lon)
    return false unless lon.to_s =~ /^-?((?:1[0-7]|[1-9])?\d(?:\.\d{1,})?|180(?:\.0{1,})?)$/
    true
  end

  def fetch_location_name(location_name)
    @fetch_location_name ||= Geocoder.search(location_name)
  end
end
