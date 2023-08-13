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

      response(200, 'Successful') do
        before do
          StubRequest
            .post(
              url: TWITTER_BASE_URL,
              path: 'oauth2/token',
              response: MockResponse::Twitter::OAuth2.access_token_data
            )

          StubRequest
            .get(
              url: TWITTER_BASE_URL,
              path: 'users/me',
              response: MockResponse::Twitter::Users.me_data
            )
        end

        run_test!
      end

      response(422, 'Unprocessable Entity') do
        before do
          StubRequest
          .post(
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
