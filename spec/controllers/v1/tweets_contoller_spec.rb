# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::TweetsController do
  let(:api_token_event) { create(:api_token_event) }
  let(:token) { api_token_event.token }

  describe "POST /create" do
    let(:city_coordinates) { { lat: -5.08921, lon: -42.8016 } }
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
    let(:create_tweet_response) do
      mock_tweet_published
        .dup
        .tap { |res| res[:body] = JSON.parse(res[:body], symbolize_names: true) }
    end

    context "when successes" do
      let(:tweet_params) { { token: token, location: location_params } }

      before do
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

      context "when location by lat and lon" do
        let(:location_params) { city_coordinates }

        before do
          expect(Geocoder).to receive(:search)
            .with(city_coordinates.values)
            .and_return([OpenStruct.new(city: city_name, coordinates: city_coordinates.values)])
        end

        it { expect { post :create, params: tweet_params }.to change(Tweet, :count).by(1) }

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['tweets']['text'])
            .to eql(create_tweet_response[:body][:data][:text])
        end
      end

      context "when location by name" do
        let(:location_params) { { name: city_name } }

        before do
          expect(Geocoder).to receive(:search)
            .with(city_name)
            .and_return([OpenStruct.new(city: city_name, coordinates: city_coordinates.values)])
            .twice
        end

        it { expect { post :create, params: tweet_params }.to change(Tweet, :count).by(1) }

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['tweets']['text'])
            .to eql(create_tweet_response[:body][:data][:text])
        end
      end
    end

    context "when failed" do
      let(:location_params) { city_coordinates }
      let(:tweet_params) { { token: token, location: location_params } }
      let(:invalid_lat) { [-91.0, 91.0].sample }
      let(:invalid_lon) { [-181.0, 181.0].sample }

      context "when token has expired" do
        before do
          api_token_event.update(expires_in: Time.current - 1.minutes)
        end

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when token not exist" do
        let(:token) { [nil, "", " "].sample }

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when latitude is invalid" do
        let(:location_params) { { lat: invalid_lat, lon: 42.80 } }

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['detail']).to eql("latitude is not valid")
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when longitude is invalid" do
        let(:location_params) { { lat: 46.0, lon: invalid_lon } }

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['detail']).to eql("longitude is not valid")
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when latitude and longitude is invalid" do
        let(:location_params) { { lat: invalid_lat, lon: invalid_lon } }

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['detail'])
            .to eql("latitude is not valid and longitude is not valid")
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when name location is null" do
        let(:location_params) { { name: [nil, "", " "].sample } }

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['detail']).to eql("params location is missing")
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when location is not found" do
        let(:location_params) { { name: "Invalid Place" } }

        before do
          expect(Geocoder).to receive(:search)
            .with(location_params[:name])
            .and_return(nil)
        end

        it do
          post :create, params: tweet_params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['detail']).to eql("location is not found")
        end

        it do
          post :create, params: tweet_params

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end
    end
  end
end
