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
  temp = data['main']['temp'].round
  description = data['weather'][0]['description']
  location = "#{data['city']}, #{data['sys']['country']}"
  time = data['timezone'].seconds.from_now

  "Tempo Atual em: #{location} (#{time.strftime("%d/%m às %H:%Mh")})
  #{icon} #{temp}ºC e #{description}"
end
