# frozen_string_literal: true

class Tweet::CreateWithWeatherInformation < ::Micro::Case
  attribute :lat
  attribute :lon
  attribute :location_name, default: -> value { value.to_s.strip }
  attribute :api_token, default: -> value { value if value.is_a?(ApiTokenEvent) }

  def call!
    validate_location_attributes
      .then(apply(:set_geocoder_coordinates))
      .then(apply(:get_weather_information))
      .then(apply(:prepare_weather_information))
      .then(apply(:build_weather_static_text))
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
      end

      errors[:location_name] = "location name not found" if geocoder_location.nil?
    end

    return Success :valid_params, result: { geocoder_location: @geocoder_location } if errors.blank?

    Failure :invalid_params, result: { message: ErrorSerializer.new(errors.values, 422) }
  end

  def set_geocoder_coordinates(geocoder_location:, **)
    lat, lon = geocoder_location.coordinates

    Success result: { lat: lat, lon: lon }
  end

  def get_weather_information(lat:, lon:, **)
    Success result: { current_weather: OpenWeatherMap::CurrentWeatherInformation.call(lat:, lon:) }
  end

  def prepare_weather_information(geocoder_location:, current_weather:, **)
    data = {}
    data.merge!(current_weather.data, 'city' => geocoder_location.city)

    Success result: { weather_information: data }
  end

  def build_weather_static_text(weather_information:, **)
    Success result: { text: WeatherStaticTextBuilder.call(weather_information) }
  end

  def publish_tweet(api_token:, text:, **)
    access_token = api_token.access_token

    tweet_published = Twitter::PublishTweet.call(access_token:, text:)
      .on_failure { |result| return Failure result: { message: result[:message] } }

    Success result: { tweet_published: tweet_published }
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

  def geocoder_location
    @geocoder_location ||= if location_name.present?
      Geocoder.search(location_name).select { |l| %w[city village].include?(l.type) }[0]
    else
      Geocoder.search([lat.to_f, lon.to_f])[0]
    end
  end
end
