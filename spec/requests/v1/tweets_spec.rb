# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "V1::Tweets", type: :request do
  describe "POST /create" do
    let(:api_token_event) { create(:api_token_event) }
    let(:city) { "Teresina" }
    let(:city_coordinates) do
      Geocoder.search(city)[0].coordinates.then { |l| { lat: l[0], lon: l[1] } }
    end

    context "when valid params" do
      let(:valid_params) { { token: api_token_event.token, location: location_params } }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get)
          .and_return(
            instance_double(
              Faraday::Response,
              body: MockOpenWeatherMapResponse.current_weather_data(city_coordinates),
              status: 200
            )
          )

        allow_any_instance_of(Faraday::Connection).to receive(:post)
          .and_return(
            instance_double(
              Faraday::Response,
              body: MockTwitterResponse::Tweets.new_tweet_data(text: location_params),
              status: 200
            )
          )
      end

      context "when location by lat and lon" do
        let(:location_params) { city_coordinates }

        it { expect { post tweets_path(params: valid_params) }.to change(Tweet, :count).by(1) }
      end

      context "when location by name" do
        let(:location_params) { { name: city } }

        it { expect { post tweets_path(params: valid_params) }.to change(Tweet, :count).by(1) }
      end
    end

    context "when invalid params" do
      let(:token_params) { api_token_event.token }
      let(:location_params) { city_coordinates }
      let(:invalid_params) { { token: token_params, location: location_params } }

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
        let(:token_params) { [nil, "", " "].sample }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when latitude is invalid" do
        let(:location_params) { { lat: 91.0, lon: 42.80 } }

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
        let(:location_params) { { lat: 46.0, lon: 181.0 } }

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
        let(:location_params) { { lat: 91.0, lon: 180.0 } }

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
