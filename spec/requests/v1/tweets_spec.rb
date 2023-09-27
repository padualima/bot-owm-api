# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe "V1::Tweets", type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:city_coordinates) { { lat: -5.08921, lon: -42.8016 } }
  let(:api_key) { create(:api_key).token }
  let(:Authorization) { "Bearer #{api_key}" }

  path '/tweets' do
    get('index tweets') do
      tags 'Tweets'
      produces 'application/json'
      security [{ bearer_auth: [], api_key: [] }]

      response(200, 'Successful') { run_test! }

      response(401, 'Unauthorized') do
        let(:api_key) { '' }

        run_test!
      end
    end
  end

  path '/tweets' do
    post('create tweets') do
      let(:city_name) { Faker::Address.city }
      let(:mock_current_wear) do
        MockResponse::OpenWeatherMap::Weather.current_weather_data(city_name: city_name)
      end
      let(:mock_tweet_published) do
        data = {}
        data.merge!(JSON.parse(mock_current_wear[:body]))
        data['city'] = city_name

        MockResponse::Twitter::Tweets
          .tweet_published_data(text: WeatherStaticTextBuilder[data])
      end
      let(:location) { { location: city_coordinates } }

      tags 'Tweets'
      produces 'application/json'
      security [{ bearer_auth: [], api_key: [] }]

      parameter name: :location, in: :query,
        schema: {
          type: :object,
          properties: {
            location: {
              type: :object,
              properties: {
                lat: { type: :number, example: 76.2592 },
                lon: { type: :number, example: -157.93604 },
                name: { type: :string, example: 'City Name' }
              }
            }
          }
        }

      response(200, 'Successful') do
        before do
          expect(Geocoder).to receive(:search)
            .with(city_coordinates.values)
            .and_return([OpenStruct.new(city: city_name, coordinates: city_coordinates.values)])

          allow(ENV).to receive(:fetch).with("OPEN_WEATHER_MAP_API_KEY").and_return('123456')
          allow(ENV).to receive(:fetch).with("OPEN_WEATHER_MAP_API_URL")
            .and_return(OPEN_WEATHER_MAP_BASE_URL)

          StubRequest.get(
            url: OPEN_WEATHER_MAP_BASE_URL,
            path: "data/2.5/weather",
            request: {
              query: {
                appid: '123456',
                lang: 'pt',
                lat: city_coordinates[:lat],
                lon: city_coordinates[:lon],
                units: 'metric'
              }
            },
            response: mock_current_wear
          )

          StubRequest.post(url: TWITTER_BASE_URL, path: 'tweets', response: mock_tweet_published)
        end

        run_test!
      end

      response(401, 'Unauthorized') do
        let(:api_key) { nil }
        run_test!
      end

      response(422, 'Unprocessable Entity') do
        let(:invalid_lat) { [-91.0, 91.0].sample }
        let(:city_coordinates) { { lat: invalid_lat, lon: -42.8016 } }

        run_test!
      end
    end
  end
end
