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

WeatherStaticTextBuilder = -> (body) do
  icon = CONDITION_CODE.dig(body['weather'][0]['icon'])
  temp = body['main']['temp']
  description = body['weather'][0]['description']
  city = body['name']
  time = body['timezone'].seconds.from_now

  "#{icon} #{temp}ºC e #{description} em #{city} em #{time.strftime("%d/%m às %H:%M:%S")}".as_json
end
