# frozen_string_literal: true

module MockOpenWeatherMapResponse
  extend self

  def current_weather_data(location)
    # TODO: ADD MORE FIELDS IF NECESSARY TO BUILD TWEET TEXT
    {
      coord: location,
      weather: [{ icon: "01n" }],
      main: { temp: (-15..39).to_a.sample },
      timezone: -18000,
      name: "Indian Heights",
      cod: 200
    }.as_json
  end
end
