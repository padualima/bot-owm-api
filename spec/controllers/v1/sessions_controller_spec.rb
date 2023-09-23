# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::SessionsController do
  let(:code_verifier) { 'code_verifier' }
  let(:code_challenge) { 'code_challenge' }
  let(:client_id) { 'example_client_id' }
  let(:client_secret) { 'example_client_secret' }
  let(:provider_host) { TWITTER_BASE_URL }
  let(:callback_uri) { 'http://example.com/auths/provider/callback' }
  let(:authorize_options) { { url: 'oauth/authorize' } }
  let(:token_options) do
    {
      method: :post,
      url: 'oauth2/token',
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    }
  end
  let(:options) do
    {
      client_id: client_id,
      client_secret: client_secret,
      url: provider_host,
      redirect_uri: callback_uri,
      authorize_options: authorize_options,
      token_options: token_options
    }
  end

  before do
    OAuth2::Configuration.instance.providers.clear

    opts = options.dup
    OAuth2::Builder.new { provider(:twitter, **opts) }
  end

  after do
    OAuth2::Configuration.instance.providers.clear
  end

  describe "GET /authorize" do
    before do
      allow(OAuth2::Twitter).to receive(:code_verifier).and_return(code_verifier)
      allow(OAuth2::Twitter).to receive(:code_challenge).and_return(code_challenge)
    end

    it "returns http success" do
      get :authorize
      expect(response).to have_http_status(:success)
    end

    it do
      get :authorize

      expect(response.parsed_body).to include_json({ data: { message: a_kind_of(String) } })
    end

    it "return a mesasge data with valid authorize_url" do
      get :authorize

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
      let(:callback_params) { { provider: :twitter2, code: code, state: state } }

      context "when invalid authorization code" do
        before do
          StubRequest.post(url: TWITTER_BASE_URL, path: 'oauth2/token', response: { status: 500 })
        end

        it do
          get :callback, params: callback_params

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it do
          get :callback, params: callback_params

          expect(response.parsed_body['errors'][0]).to include_json({ detail: a_kind_of(String) })
        end

        it do
          get :callback, params: callback_params

          expect(response.parsed_body['errors'][0]['status']).to eql(422)
        end
      end

      context "when valid authorization code" do
        context "when the user not exist" do
          before do
            StubRequest.post(
              url: TWITTER_BASE_URL,
              path: 'oauth2/token',
              response: MockResponse::Twitter::OAuth2.access_token_data
            )

            StubRequest.get(
              url: TWITTER_BASE_URL,
              path: 'users/me',
              response: MockResponse::Twitter::Users.me_data
            )
          end

          it do
            get :callback, params: callback_params

            expect(response.parsed_body).to include_json({ users: { token: a_kind_of(String) } })
          end

          it "return a create user and api_token_event" do
            expect { get :callback, params: callback_params }.to change(User, :count).by(1)
              .and change(ApiTokenEvent, :count).by(1)
          end
        end

        context "when the user already exists" do
          let(:api_token_event) { create(:api_token_event) }
          let(:user) { api_token_event.user }
          let(:new_api_token_event) { build(:api_token_event, user: user) }
          let(:access_token) { new_api_token_event.access_token }

          before do
            StubRequest.post(
              url: TWITTER_BASE_URL,
              path: 'oauth2/token',
              response: MockResponse::Twitter::OAuth2
                .access_token_data(access_token: access_token)
            )

            StubRequest.get(
              url: TWITTER_BASE_URL,
              path: 'users/me',
              response: MockResponse::Twitter::Users.me_data(id: user.uid)
            )
          end

          it "return new token" do
            get :callback, params: callback_params

            fetch_api_token_event =
              ApiTokenEvent.find_by(token: response.parsed_body['users']['token'])

            expect(response.parsed_body).to include_json({ users: { token: a_kind_of(String) } })
            expect(fetch_api_token_event.user.id).to eql(api_token_event.user.id)
            expect(fetch_api_token_event.id).to eql(api_token_event.id.succ)
          end
        end
      end

      context "when valid authorization code with custom params redirect_uri" do
        let(:redirect_uri) { 'https://custom_redirect' }
        let(:callback_params) do
          { provider: :twitter2, code: code, state: state, redirect_uri: redirect_uri}
        end

        context "when the user not exist" do
          before do
            StubRequest.post(
              url: TWITTER_BASE_URL,
              path: 'oauth2/token',
              response: MockResponse::Twitter::OAuth2.access_token_data
            )

            StubRequest.get(
              url: TWITTER_BASE_URL,
              path: 'users/me',
              response: MockResponse::Twitter::Users.me_data
            )
          end

          it do
            get :callback, params: callback_params

            expect(response.parsed_body).to include_json({ users: { token: a_kind_of(String) } })
          end

          it "return a create user and api_token_event" do
            expect { get :callback, params: callback_params }.to change(User, :count).by(1)
              .and change(ApiTokenEvent, :count).by(1)
          end
        end

        context "when the user already exists" do
          let(:api_token_event) { create(:api_token_event) }
          let(:user) { api_token_event.user }
          let(:new_api_token_event) { build(:api_token_event, user: user) }
          let(:access_token) { new_api_token_event.access_token }

          before do
            StubRequest.post(
              url: TWITTER_BASE_URL,
              path: 'oauth2/token',
              response: MockResponse::Twitter::OAuth2
                .access_token_data(access_token: access_token)
            )

            StubRequest.get(
              url: TWITTER_BASE_URL,
              path: 'users/me',
              response: MockResponse::Twitter::Users.me_data(id: user.uid)
            )
          end

          it "return new token" do
            get :callback, params: callback_params

            fetch_api_token_event =
              ApiTokenEvent.find_by(token: response.parsed_body['users']['token'])

            expect(response.parsed_body).to include_json({ users: { token: a_kind_of(String) } })
            expect(fetch_api_token_event.user.id).to eql(api_token_event.user.id)
            expect(fetch_api_token_event.id).to eql(api_token_event.id.succ)
          end
        end
      end
    end

    context "when not receive twitter callback" do
      it do
        expect{ get callback_path }.to raise_error(
          ActionController::UrlGenerationError,
          'No route matches {:action=>"callback", :controller=>"v1/sessions", :format=>:json}, ' \
          "missing required keys: [:provider]"
        )
      end
    end

    context "when not receive callback params, state and code" do
      it do
        expect{ get callback_path(:twitter2) }.to raise_error(
          ActionController::UrlGenerationError,
          'No route matches {:action=>"/auths/twitter2/callback", ' \
          ':controller=>"v1/sessions", :host=>"localhost:3000"}'
        )
      end
    end
  end
end
