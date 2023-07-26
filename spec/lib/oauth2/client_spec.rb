# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth2::Client do
  let(:client_id) { 'abc123' }
  let(:client_secret) { 'secret' }
  let(:provider_host) { 'http://example.com/' }
  let(:callback_uri) { 'http://example.com/auths/provider/callback' }
  let(:options) { { url: provider_host, redirect_uri: callback_uri } }
  let(:authorize_options) { { url: 'oauth/authorize' } }

  subject { described_class.new(client_id: client_id, client_secret: client_secret, **options) }

  describe '#initialize' do
    let(:default_options) do
      {
        redirect_uri: nil,
        authorize_options: authorize_options,
        token_options: {
          method: :post,
          url: 'oauth/token',
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        },
        logger: ::Logger.new($stdout)
      }
    end

    it 'initializes with empty client_id, client_secret and url' do
      client = described_class.new

      expect(client.client_id).to be_nil
      expect(client.client_secret).to be_nil
      expect(client.url).to be_nil
    end

    it 'initializes with the default_options keys' do
      client = described_class.new

      expect(client.options.keys).to eq(default_options.keys)
    end
  end

  describe '#authorize_url' do
    let(:code) { '12345' }
    let(:params) { { code: code } }

    it 'builds a valid URL with parameters' do
      authorize_url = subject.authorize_url(params)

      expect(authorize_url).to be_a(String)

      expected_authorize_url =
        "#{provider_host}#{authorize_options[:url]}?" \
        "code=#{code}&redirect_uri=#{CGI.escape(callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds a valid URL with a different redirect_uri' do
      another_callback_uri = 'http://localhost:3000/auths/provider/callback'

      authorize_url = subject.authorize_url(params.merge(redirect_uri: another_callback_uri))

      expected_authorize_url =
        "#{provider_host}#{authorize_options[:url]}?" \
        "code=#{code}&redirect_uri=#{CGI.escape(another_callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds a valid URL without redirect_uri' do
      subject.options.delete(:redirect_uri)

      authorize_url = subject.authorize_url(params)

      expected_authorize_url = "#{provider_host}#{authorize_options[:url]}?code=#{code}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds an invalid URL without a base url' do
      allow(subject).to receive(:url).and_return(nil)

      authorize_url = subject.authorize_url(params)

      expected_authorize_url =
        "http:/#{authorize_options[:url]}?" \
        "code=#{code}&redirect_uri=#{CGI.escape(callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds a valid URL with a full authorize_url' do
      another_authorize_url = 'http://another.example.com/auths/oauth/authorize'
      subject.options[:authorize_options][:url] = another_authorize_url

      authorize_url = subject.authorize_url(params)

      expected_authorize_url =
        "#{another_authorize_url}?code=#{code}&redirect_uri=#{CGI.escape(callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'does not build a URL with invalid params' do
      expect { subject.authorize_url(1) }
        .to raise_error(ArgumentError, '`params` is expected to be a Hash')
    end
  end

  describe '#connection' do
    it 'is an instance of faraday with url from provider' do
      expect(subject.connection).to be_a(Faraday::Connection)
      expect(subject.connection.url_prefix.to_s).to eq(provider_host)
    end
  end

  describe '#redirect_uri' do
    it { expect(subject.send(:redirect_uri)).to eq(subject.options[:redirect_uri]) }
  end

  describe '#redirect_uri_params' do
    let(:redirect_uri_params) { { redirect_uri: subject.options[:redirect_uri] } }

    it { expect(subject.send(:redirect_uri_params)).to eq(redirect_uri_params) }

    it 'empty hash when unless redirect_uri options' do
      subject.options.delete(:redirect_uri)

      expect(subject.send(:redirect_uri_params)).to eq({})
    end
  end

  describe '#authorize_url_params' do
    let(:redirect_uri_params) { { redirect_uri: subject.options[:redirect_uri] } }
    let(:code) { '12345' }
    let(:params) { { 'code' => code } }
    let(:authorize_url_params) do
      redirect_uri_params
        .merge(params.transform_keys(&:to_sym))
        .transform_keys(&:to_s)
    end

    it 'returns a redirect_uri and params Hash with stringify hash keys' do
      expect(subject.send(:authorize_url_params, params)).to eq(authorize_url_params)
    end

    it 'returns only params with stringify hash keys when does not present redirect_uri' do
      subject.options.delete(:redirect_uri)

      expect(subject.send(:authorize_url_params, params)).to eq(params.transform_keys(&:to_s))
    end
  end
end
