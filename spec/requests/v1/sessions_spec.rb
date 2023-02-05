# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "V1::Sessions", type: :request do
  describe "GET /authorize" do
    it "returns http success" do
      get authorize_path
      expect(response).to have_http_status(:success)
    end

    it "return a mesasge data with string" do
      get authorize_path

      expect(response.parsed_body).to include_json({ data: { message: a_kind_of(String) } })
    end

    it "return a mesasge data with valid authorize_url" do
      code_verifier = Helpers.generate_code_verifier
      code_challenge = Helpers.generate_code_challenge(code_verifier)
      authorize_url = Helpers.generate_authorize_url(code_verifier, code_challenge)

      allow(Clients::Twitter::Utils::PKCE).to receive(:code_verifier).and_return(code_verifier)
      allow(Clients::Twitter::Utils::PKCE).to receive(:code_challenge)
        .with(code_verifier)
        .and_return(code_challenge)

      get authorize_path

      expect(response.parsed_body["data"]["message"]).to eql(authorize_url)
    end
  end

  describe "GET /callback" do
    context "when receive twitter callback" do
      let(:state) { Helpers.generate_code_verifier }
      let(:code) { SecureRandom.hex(10) }
      let(:twitter_callback) { callback_path(:twitter2, code: code, state: state) }

      context "invalid authorization code" do
        it 'return unprocessable en`tity' do
          get twitter_callback

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "valid authorization code" do
        before do
          allow_any_instance_of(Faraday::Connection).to receive(:post)
            .and_return(
              instance_double(Faraday::Response, body: Helpers.access_token_response, status: 200)
            )

          allow_any_instance_of(Faraday::Connection).to receive(:get)
            .and_return(
              instance_double(Faraday::Response, body: Helpers.me_response, status: 200)
            )
        end

        it 'return a token data' do
          get twitter_callback

          expect(response.parsed_body).to include_json({ data: { token: a_kind_of(String) } })
        end

        it 'return a create user and api_token_event' do
          expect { get twitter_callback }.to change(User, :count).by(1)
            .and change(ApiTokenEvent, :count).by(1)
        end

        it 'return access_token and find user and update'
      end
    end

    context "when not receive twitter callback" do
      it "return not found routing exception unless require params" do
        expect{ get callback_path(:twitter2) }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
