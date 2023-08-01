# frozen_string_literal: true

require 'rails_helper'
require 'oauth2/strategies/auth_code'

RSpec.describe OAuth2::Strategies::AuthCode do
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
      url: provider_host,
      redirect_uri: callback_uri,
      authorize_options: authorize_options,
      token_options: token_options
    }
  end
  let(:client) { OAuth2::Client.new(id: client_id, secret: client_secret, **options) }

  before { OAuth2::Configuration.instance.providers.clear }

  subject { described_class.new(client) }

  describe '#authorize_url' do
    it 'raises ArgumentError if client_secret is present in params' do
      expect { subject.authorize_url(client_secret: 'example_client_secret') }
        .to raise_error(ArgumentError, /client_secret is not allowed params/)
    end

    it 'returns the correct authorize URL with default params' do
      authorize_url = subject.authorize_url
      expect(authorize_url).to include('response_type=code')
      expect(authorize_url).to include("client_id=#{client_id}")
    end

    it 'returns the correct authorize URL with custom params' do
      custom_params = { response_type: 'custom_response_type', custom_param: 'custom_value' }
      authorize_url = subject.authorize_url(**custom_params)

      expect(authorize_url).to include('response_type=code')
      expect(authorize_url).to include("client_id=#{client_id}")
      expect(authorize_url).to include('custom_param=custom_value')
    end
  end

  describe '#get_token' do
    before do
      mock_response =
        instance_double(Faraday::Response, body: { token: 'Token' }.to_json, status: 200)

      allow_any_instance_of(OAuth2::Client).to receive(:run_request).and_return(mock_response)
    end

    it 'does not raises ArgumentError if client_secret is present in params' do
      expect { subject.get_token('example_code', client_secret: 'example_client_secret') }
        .not_to raise_error
    end

    it 'returns the correct access token params with default code' do
      access_token_params = subject.get_token('example_code')

      expect(access_token_params.body['token']).to eq('Token')
      expect(access_token_params.status).to eq(200)
    end

    it 'returns the correct access token params with custom params' do
      access_token_params = subject.get_token('example_code', custom_param: 'custom_value')

      expect(access_token_params.body['token']).to eq('Token')
      expect(access_token_params.status).to eq(200)
    end
  end
end
