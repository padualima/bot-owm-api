# frozen_string_literal: true

module MockResponse
  module Twitter
    module OAuth2
      extend self

      def access_token_data(access_token: SecureRandom.hex(10), status: 200)
        {
          status: status,
          body: {
            token_type: "bearer",
            expires_in: 7200,
            access_token: access_token,
            scope: "tweet.write users.read tweet.read offline.access",
            refresh_token: SecureRandom.hex(10)
          }.to_json
        }
      end
    end

    module Users
      extend self

      def me_data(id: SecureRandom.rand(10000..20000), status: 200)
        {
          status: status,
          body: {
            data: {
              id: id,
              name: Faker::Name.name,
              username: Faker::Internet.username(specifier: 5..10)
            }
          }.to_json
        }
      end
    end

    module Tweets
      extend self

      def tweet_published_data(text: Faker::Lorem.sentence, status: 201)
        {
          status: status,
          body: {
            data: {
              edit_history_tweet_ids: [SecureRandom.rand(100000..900000).to_s],
              id: SecureRandom.rand(100000..900000).to_s,
              text: text
            }
          }.to_json
        }
      end
    end
  end

  module OpenWeatherMap
    module Weather
      require_relative '../../app/services/weather_static_text_builder'

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

      def current_weather_data(city_name: Faker::Address.city, status: 200)
        return unless city_name

        {
          status: status,
          body: {
            weather: [{
              description: condition_description[0],
              icon: CONDITION_CODE.dig(condition_description[1].sample)
            }],
            main: { temp: (-15..39).to_a.sample },
            timezone: -10800,
            sys: { country: 'BR' },
            name: city_name,
            cod: 200
            }.to_json
        }
      end
    end
  end
end
