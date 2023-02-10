# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "V1::Tweets", type: :request do
  describe "POST /create" do
    context "when valid params" do
      let(:api_token_event) { create(:api_token_event) }
      # TODO: mudar parâmetro quando tiver criado a api OpenWeatherMap
      let(:location_params) { Faker::Address.city }
      let(:valid_params) { { token: api_token_event.token, location: location_params } }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post)
          .and_return(
            instance_double(
              Faraday::Response,
              body: MockTwitterResponse::Tweets.new_tweet_data(text: location_params),
              status: 200
            )
          )
      end

      it { expect { post tweets_path(params: valid_params) }.to change(Tweet, :count).by(1) }
    end

    context "when invalid params" do
      let(:api_token_event) { create(:api_token_event) }
      let(:location_params) { Faker::Address.city }
      let(:token_params) { api_token_event.token }
      let(:invalid_params) { { token: token_params, location: location_params } }

      context "when token has expired" do
        before do
          api_token_event.update(expires_in: Time.current - 1.minutes)
        end

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when token not exist" do
        let(:token_params) { [nil, "", " "].sample }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when location is invalid" do
        let(:location_params) { [nil, "", " "].sample }

        it do
          post tweets_path(params: invalid_params)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
