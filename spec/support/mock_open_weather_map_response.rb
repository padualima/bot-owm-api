# frozen_string_literal: true

require_relative '../../app/services/weather_static_text_builder'

module MockOpenWeatherMapResponse
  extend self

  def condition_description
    # TODO: description internacionalization key
    {
      'céu limpo' => ['01d', '01n'],
      'poucas nuvens' => ['02d', '02n'],
      'nuvens dispersas' => ['03d', '03n'],
      'nuvens quebradas' => ['04d', '04n'],
      'chuva fraca' => ['09d', '09n'],
      'chuva' => ['10d', '10n'],
      'trovoada' => ['11d', '11n'],
      'neve' => ['13d', '13n'],
      'névoa' => ['50d', '50n']
    }.to_a.sample
  end

  def current_weather_data(city_name)
    return unless city_name

    {
      weather: [{
        description: condition_description[0],
        icon: CONDITION_CODE.dig(condition_description[1].sample)
      }],
      main: { temp: (-15..39).to_a.sample },
      timezone: -10800,
      sys: { country: 'BR' },
      name: city_name,
      cod: 200
    }.as_json
  end
end
