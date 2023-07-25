# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth2::Client do
  let(:client_id) { 'abc123' }
  let(:client_secret) { 'secret' }
  let(:provider_host) { 'http://example.com/' }
  let(:callback_uri) { 'http://example.com/auths/provider/callback' }
  let(:options) { { url: provider_host, redirect_uri: callback_uri } }

  subject { described_class.new(client_id: client_id, client_secret: client_secret, **options) }

  describe '#initialize' do
    it 'initializes with empty client_id, client_secret and url' do
      client = described_class.new

      expect(client.client_id).to be_nil
      expect(client.client_secret).to be_nil
      expect(client.url).to be_nil
    end

    it 'initializes with the default_options keys' do
      client = described_class.new

      expect(client.options.keys).to eq(client.send(:default_options).keys)
    end
  end

  describe '#authorize_url' do
    let(:code) { '12345' }
    let(:params) { { code: code } }

    it 'builds a valid URL with parameters' do
      authorize_url = subject.authorize_url(params)

      expect(authorize_url).to be_a(String)

      expected_authorize_url =
        "#{provider_host}#{subject.options[:authorize_url]}?" \
        "code=#{code}&redirect_uri=#{CGI.escape(callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds a valid URL with a different redirect_uri' do
      another_callback_uri = 'http://localhost:3000/auths/provider/callback'

      authorize_url = subject.authorize_url(params.merge(redirect_uri: another_callback_uri))

      expected_authorize_url =
        "#{provider_host}#{subject.options[:authorize_url]}?" \
        "code=#{code}&redirect_uri=#{CGI.escape(another_callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds a valid URL without redirect_uri' do
      subject.options.delete(:redirect_uri)

      authorize_url = subject.authorize_url(params)

      expected_authorize_url = "#{provider_host}#{subject.options[:authorize_url]}?code=#{code}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds an invalid URL without a base url' do
      allow(subject).to receive(:url).and_return(nil)

      authorize_url = subject.authorize_url(params)

      expected_authorize_url =
        "http:/#{subject.options[:authorize_url]}?" \
        "code=#{code}&redirect_uri=#{CGI.escape(callback_uri)}"

      expect(authorize_url).to eq(expected_authorize_url)
    end

    it 'builds a valid URL with a full authorize_url' do
      another_authorize_url = 'http://another.example.com/auths/oauth/authorize'
      subject.options[:authorize_url] = another_authorize_url

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

  describe '#default_options' do
    it 'only specific defaults options' do
      default_options = %i[authorize_url token_url redirect_uri logger]

      expect(subject.send(:default_options).keys).to eq(default_options)
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
    let(:authorize_url_params) { redirect_uri_params.merge(params.transform_keys(&:to_sym)) }

    it { expect(subject.send(:authorize_url_params, params)).to eq(authorize_url_params) }

    it 'no redirect url when not present' do
      subject.options.delete(:redirect_uri)

      expect(subject.send(:authorize_url_params, params)).to eq(params.transform_keys(&:to_sym))
    end
  end
end
