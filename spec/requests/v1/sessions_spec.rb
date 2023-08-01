# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe "V1::Sessions", type: :request do

  describe 'Sessions Swagger', swagger_doc: 'v1/swagger.yaml' do
    path '/authorize' do
      get('authorize session') do
        tags 'Sessions'
        produces 'application/json'

        response(200, 'Successful') do

          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          end
          run_test!
        end
      end
    end

    path '/auths/{provider}/callback' do
      parameter name: :provider, in: :path, type: :string, description: 'provider'
      parameter name: :state, in: :query, type: :string, required: true
      parameter name: :code, in: :query, type: :string, required: true

      get('callback session') do
        tags 'Sessions'
        produces 'application/json'

        response(200, 'Successful') do
          before do
            allow_any_instance_of(Faraday::Connection).to receive(:post)
              .and_return(
                instance_double(
                  Faraday::Response,
                  body: MockTwitterResponse::OAuth2.access_token_data,
                  status: 200
                )
              )

            allow_any_instance_of(Faraday::Connection).to receive(:get)
              .and_return(
                instance_double(
                  Faraday::Response,
                  body: MockTwitterResponse::Users.me_data,
                  status: 200
                )
              )
          end

          let(:provider) { 'twitter2' }
          let(:state) { 'state' }
          let(:code) { 'code' }

          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          end
          run_test!
        end

        response(422, 'Unprocessable Entity') do
          let(:provider) { 'twitter2' }
          let(:state) { 'state' }
          let(:code) { 'code' }

          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          end
          run_test!
        end
      end
    end
  end

  describe "GET /authorize" do
    let(:code_verifier) { 'code_verifier' }
    let(:code_challenge) { 'code_challenge' }
    let(:client_id) { 'example_client_id' }
    let(:client_secret) { 'example_client_secret' }
    let(:provider_host) { 'http://example.com/' }
    let(:callback_uri) { 'http://example.com/auths/provider/callback' }
    let(:authorize_options) { { url: 'oauth/authorize' } }
    let(:token_options) do
      {
        method: :post,
        url: 'oauth/token',
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      }
    end
    let(:options) do
      {
        client_id: client_id,
        client_secret: client_secret,
        url: provider_host,
        redirect_uri: callback_uri,
        authorize_options: authorize_options
      }
    end

    before do
      OAuth2::Configuration.instance.providers.clear

      opts = options.dup
      OAuth2::Builder.new { provider(:twitter, **opts) }

      allow(OAuth2::Twitter).to receive(:code_verifier).and_return(code_verifier)
      allow(OAuth2::Twitter).to receive(:code_challenge).and_return(code_challenge)
    end

    it "returns http success" do
      get authorize_path
      expect(response).to have_http_status(:success)
    end

    it do
      get authorize_path

      expect(response.parsed_body).to include_json({ data: { message: a_kind_of(String) } })
    end

    it "return a mesasge data with valid authorize_url" do
      get authorize_path

      message_data = response.parsed_body["data"]["message"]

      expect(message_data).to include("client_id=#{client_id}")
      expect(message_data).to include("state=#{code_verifier}")
      expect(message_data).to include("code_challenge=#{code_challenge}")
      expect(message_data).to include("scope=tweet.read+users.read+tweet.write+offline.access")
      expect(message_data).to include('response_type=code')
      expect(message_data).to include('code_challenge_method=S256')
    end
  end

  describe "GET /callback" do
    context "when receive twitter callback" do
      let(:state) { 'code_verifier' }
      let(:code) { SecureRandom.hex(10) }
      let(:twitter_callback) { callback_path(:twitter2, code: code, state: state) }

      context "when invalid authorization code" do
        it "return unprocessable entity status" do
          get twitter_callback
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          get twitter_callback

          expect(response.parsed_body['errors'][0]).to include_json({ detail: a_kind_of(String) })
        end

        it "return htpp status" do
          get twitter_callback

          expect(response.parsed_body['errors'][0]['status'])
            .to eql(422)
        end
      end

      context "when valid authorization code" do
        context "when the user not exist" do
          before do
            allow_any_instance_of(Faraday::Connection).to receive(:post)
              .and_return(
                instance_double(
                  Faraday::Response,
                  body: MockTwitterResponse::OAuth2.access_token_data,
                  status: 200
                )
              )

            allow_any_instance_of(Faraday::Connection).to receive(:get)
              .and_return(
                instance_double(
                  Faraday::Response,
                  body: MockTwitterResponse::Users.me_data,
                  status: 200
                )
              )
          end

          it "return a token data" do
            get twitter_callback

            expect(response.parsed_body).to include_json({ users: { token: a_kind_of(String) } })
          end

          it "return a create user and api_token_event" do
            expect { get twitter_callback }.to change(User, :count).by(1)
              .and change(ApiTokenEvent, :count).by(1)
          end
        end

        context "when the user already exists" do
          let(:api_token_event) { create(:api_token_event) }
          let(:user) { api_token_event.user }
          let(:new_api_token_event) { build(:api_token_event, user: user) }
          let(:access_token) { new_api_token_event.access_token }

          before do
            allow_any_instance_of(Faraday::Connection).to receive(:post)
              .and_return(
                instance_double(
                  Faraday::Response,
                  body: MockTwitterResponse::OAuth2.access_token_data(access_token: access_token),
                  status: 200
                )
              )

            allow_any_instance_of(Faraday::Connection).to receive(:get)
              .and_return(
                instance_double(
                  Faraday::Response,
                  body: MockTwitterResponse::Users.me_data(id: user.uid),
                  status: 200
                )
              )
          end

          it "return new token" do
            get twitter_callback

            response_body = response.parsed_body

            fetch_api_token_event =
              ApiTokenEvent.find_by(token: response_body['users']['token'])

            expect(response_body).to include_json({ users: { token: a_kind_of(String) } })
            expect(fetch_api_token_event.user.id).to eql(api_token_event.user.id)
            expect(fetch_api_token_event.id).to eql(api_token_event.id.succ)
          end
        end
      end
    end

    context "when not receive twitter callback" do
      it "return not found routing exception unless require params" do
        expect{ get callback_path(:twitter2) }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
