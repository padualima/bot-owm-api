# frozen_string_literal: true

class Tweet::CreateWithWeatherInformation < ::Micro::Case
  attribute :lat
  attribute :lon
  attribute :location_name, default: -> value { value.to_s.strip }

  def call!
    validate_location_attributes
      # .then(OpenWeatherMap::CurrentWeatherInformation)
      # .then(WeatherStaticTextBuilder)
      # .then(Twitter::PublishTweet)
      # .then(Tweet::Create)
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
      elsif location_name
        if Geocoder.search(location_name).empty?
          errors[:location_name] = "location name not found"
        end
      end
    end

    errors.blank? ? Success(:valid_params) : Failure(:invalid_params, result: { errors: errors })
  end

  def latitude_is_valid?(lat)
    return false unless lat.to_s =~ /^-?([1-8]?\d(?:\.\d{1,})?|90(?:\.0{1,6})?)$/
    true
  end

  def longitude_is_valid?(lon)
    return false unless lon.to_s =~ /^-?((?:1[0-7]|[1-9])?\d(?:\.\d{1,})?|180(?:\.0{1,})?)$/
    true
  end
end
