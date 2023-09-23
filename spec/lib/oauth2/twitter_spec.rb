# frozen_string_literal: true

require 'rails_helper'
require 'oauth2/twitter'

RSpec.describe OAuth2::Twitter do
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
      authorize_options: authorize_options,
      token_options: token_options
    }
  end

  before do
    OAuth2::Configuration.instance.providers.clear

    opts = options.dup
    OAuth2::Builder.new { provider(:twitter, **opts) }

    allow(OAuth2::Twitter).to receive(:scopes).and_return('tweet.read users.read')
    allow(OAuth2::PKCEGenerator).to receive(:code_verifier).and_return('example_code_verifier')
    allow(OAuth2::PKCEGenerator).to receive(:code_challenge).and_return('example_code_challenge')
  end

  describe '#authorize_url' do
    it 'returns the correct authorize URL' do
      subject = described_class.authorize_url

      expect(subject).to include(
        "client_id=example_client_id&" \
        "code_challenge=example_code_challenge&" \
        "code_challenge_method=S256&" \
        "redirect_uri=#{CGI.escape(callback_uri)}&" \
        "response_type=code&" \
        "scope=tweet.read+users.read&" \
        "state=example_code_verifier"
      )
    end

    it 'returns the custom auth_code authorize URL with options' do
      redirect_uri = 'https://custom_redirect'
      scopes = %w[tweet.write offline.access]

      subject = described_class.authorize_url(redirect_uri: redirect_uri, scope: scopes.join(' '))

      expect(subject).to include(
        "client_id=example_client_id&" \
        "code_challenge=example_code_challenge&" \
        "code_challenge_method=S256&" \
        "redirect_uri=#{CGI.escape(redirect_uri)}&" \
        "response_type=code&" \
        "scope=#{scopes.join('+')}&" \
        "state=example_code_verifier"
      )
    end


    it 'does not return auth_code authorize URL with options not supported' do
      expect { described_class.authorize_url('invalid_params') }
        .to raise_error(ArgumentError, /wrong number of arguments/)
    end
  end

  describe '#access_token' do
    subject { described_class.access_token('example_state', 'example_code') }

    before do
      allow_any_instance_of(OAuth2::Strategies::AuthCode)
        .to receive(:get_token)
        .and_return('access_token')
    end

    it 'returns the correct access token' do
      expect(subject).to eq('access_token')
    end
  end
end
