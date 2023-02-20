# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe "V1::Tweets", type: :request do
  let(:api_token_event) { create(:api_token_event) }
  let(:token) { api_token_event.token }
  let(:city_coordinates) { { lat: -5.08921, lon: -42.8016 } }
  let(:city_name) { Geocoder.search(city_coordinates.values)[0].city }
  let(:mock_current_wear) { MockOpenWeatherMapResponse.current_weather_data(city_name) }
  let(:mock_tweet_published) do
    data = {}
    data.merge!(mock_current_wear)
    data['city'] = city_name

    MockTwitterResponse::Tweets.tweet_published_data(text: WeatherStaticTextBuilder.call(data))
  end

  describe 'Tweets Swagger', swagger_doc: 'v1/swagger.yaml' do
    path '/tweets' do
      post('create tweets') do
        tags 'Tweets'
        produces 'application/json'

        parameter name: :token, in: :query, type: :string, required: true
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

        let(:location) { { location: city_coordinates } }

        response(200, 'Successful') do
          before do
            allow_any_instance_of(Faraday::Connection).to receive(:get)
              .and_return(instance_double(Faraday::Response, body: mock_current_wear, status: 200))

            allow_any_instance_of(Faraday::Connection).to receive(:post)
              .and_return(instance_double(Faraday::Response, body: mock_tweet_published, status: 201))
          end

          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          end
          run_test!
        end

        response(404, 'Token Not Found') do
          let(:token) { nil }
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

  describe "POST /create" do
    context "when valid params" do
      let(:valid_params) { { token: token, location: location_params } }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get)
          .and_return(instance_double(Faraday::Response, body: mock_current_wear, status: 200))

        allow_any_instance_of(Faraday::Connection).to receive(:post)
          .and_return(instance_double(Faraday::Response, body: mock_tweet_published, status: 201))
      end

      context "when location by lat and lon" do
        let(:location_params) { city_coordinates }

        it { expect { post tweets_path(params: valid_params) }.to change(Tweet, :count).by(1) }

        it do
          post tweets_path(params: valid_params)

          expect(response.parsed_body['tweets']['text'])
            .to eql(mock_tweet_published['data']['text'])
        end
      end

      context "when location by name" do
        let(:location_params) { { name: city_name } }

        it { expect { post tweets_path(params: valid_params) }.to change(Tweet, :count).by(1) }

        it do
          post tweets_path(params: valid_params)

          expect(response.parsed_body['tweets']['text'])
            .to eql(mock_tweet_published['data']['text'])
        end
      end
    end

    context "when invalid params" do
      let(:location_params) { city_coordinates }
      let(:invalid_params) { { token: token, location: location_params } }
      let(:invalid_lat) { [-91.0, 91.0].sample }
      let(:invalid_lon) { [-181.0, 181.0].sample }

      context "when token has expired" do
        before do
          api_token_event.update(expires_in: Time.current - 1.minutes)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when token not exist" do
        let(:token) { [nil, "", " "].sample }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when latitude is invalid" do
        let(:location_params) { { lat: invalid_lat, lon: 42.80 } }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['detail']).to eql("latitude is not valid")
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when longitude is invalid" do
        let(:location_params) { { lat: 46.0, lon: invalid_lon } }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['detail']).to eql("longitude is not valid")
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when latitude and longitude is invalid" do
        let(:location_params) { { lat: invalid_lat, lon: invalid_lon } }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['detail'])
            .to eql("latitude is not valid and longitude is not valid")
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when name location is null" do
        let(:location_params) { { name: [nil, "", " "].sample } }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['detail']).to eql("params location is missing")
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when name location is not found" do
        let(:location_params) { { name: "Invalid Place" } }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['detail']).to eql("location name not found")
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end
    end
  end
end
