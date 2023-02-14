CONDITION_CODE = {
  '01d' => '☀️',
  '02d' => '⛅',
  '03d' => '☁',
  '04d' => '☁☁',
  '09d' => '🌧',
  '10d' => '🌦',
  '11d' => '⛈️',
  '13d' => '❄️',
  '50d' => '🌫',
  '01n' => '🌙',
  '02n' => '⛅',
  '03n' => '☁',
  '04n' => '☁☁',
  '09n' => '🌧',
  '10n' => '🌦',
  '11n' => '⛈️',
  '13n' => '❄️',
  '50n' => '🌫',
}

WeatherStaticTextBuilder = -> (data) do
  icon = CONDITION_CODE.dig(data['weather'][0]['icon'])
  temp = data['main']['temp']
  description = data['weather'][0]['description']
  city = data['city']
  time = data['timezone'].seconds.from_now

  "#{icon} #{temp}ºC e #{description} em #{city} em #{time.strftime("%d/%m às %H:%M:%S")}".as_json
end
