# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe "V1::Sessions", type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/authorize' do
    get('authorize session') do
      tags 'Sessions'
      produces 'application/json'

      response(200, 'Successful') { run_test! }
    end
  end

  path '/auths/{provider}/callback' do
    let(:provider) { 'twitter2' }
    let(:state) { 'state' }
    let(:code) { 'code' }

    parameter name: :provider, in: :path, type: :string, description: 'provider'
    parameter name: :state, in: :query, type: :string, required: true
    parameter name: :code, in: :query, type: :string, required: true

    get('callback session') do
      tags 'Sessions'
      produces 'application/json'

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

      response(200, 'Successful') do
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

        run_test!
      end

      response(422, 'Unprocessable Entity') do
        before do
          StubRequest.post(
            url: TWITTER_BASE_URL,
            path: 'oauth2/token',
            response: { status: 500 }
          )
        end

        run_test!
      end
    end
  end
end
