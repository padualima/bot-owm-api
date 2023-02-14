# frozen_string_literal: true

class OpenWeatherMap::CurrentWeatherInformation < ::Micro::Case
  attribute :lat, default: proc(&:to_f)
  attribute :lon, default: proc(&:to_f)

  def call!
    res = Clients::OpenWeatherMap::V3::Weather.current(lat: lat, lon: lon)

    return Success result: res.body if res.status.eql?(200)

    Failure result: { message: ErrorSerializer.new("Get Current Weather Failed", 422) }
  end
end
