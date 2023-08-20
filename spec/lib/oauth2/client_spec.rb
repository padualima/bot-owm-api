# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth2::Client do
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'secret' }
  let(:provider_host) { 'http://example.com/' }
  let(:authentication_scheme) { :basic_auth }
  let(:callback_uri) { 'http://example.com/auths/provider/callback' }
  let(:options) { { url: provider_host, redirect_uri: callback_uri } }
  let(:authorize_options) { { url: 'oauth/authorize' } }
  let(:token_options) do
    {
      method: :post,
      url: 'oauth/token',
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    }
  end
  let(:redirect_uri_params) { { redirect_uri: callback_uri } }

  subject { described_class.new(id: client_id, secret: client_secret, **options) }

  describe '#initialize' do
    let(:default_options) do
      {
        redirect_uri: nil,
        authentication_scheme: authentication_scheme,
        authorize_options: authorize_options,
        token_options: token_options,
        logger: ::Logger.new($stdout)
      }
    end

    it 'initializes with empty client_id, client_secret and url' do
      client = described_class.new

      expect(client.id).to be_nil
      expect(client.secret).to be_nil
      expect(client.url).to be_nil
      expect(client.options.except(:logger)).to eq(default_options.except(:logger))
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

  describe '#get_token' do
    let(:params) { { code: 1234, grant_type: 'authorization_code' } }

    it 'returns with access_token response' do
      mock_response = instance_double(Faraday::Response, body: params.to_json, status: 200)

      allow(subject.connection).to receive(:run_request).and_return(mock_response)

      response = subject.get_token(params)

      expect(response.status).to eq(200)
      expect(response.body).to eq(params.as_json)
    end

    it 'raise an Exception when invalid params' do
      expect { subject.get_token('') }
        .to raise_error(ArgumentError, '`params` is expected to be a Hash')
    end
  end

  describe '#auth_code' do
    it 'returns an instance of OAuth2::Strategies::AuthCode' do
      expect(subject.auth_code).to be_an_instance_of(OAuth2::Strategies::AuthCode)
    end

    it 'passes self as an argument to the AuthCode strategy' do
      auth_code_strategy = instance_double(OAuth2::Strategies::AuthCode)
      expect(OAuth2::Strategies::AuthCode).to receive(:new).with(subject).and_return(auth_code_strategy)
      expect(subject.auth_code).to eq(auth_code_strategy)
    end
  end

  describe '#connection' do
    it 'is an instance of faraday with url from provider' do
      expect(subject.connection).to be_a(Faraday::Connection)
      expect(subject.connection.url_prefix.to_s).to eq(provider_host)
    end
  end

  describe '#validate_params' do
    it 'raises ArgumentError when params is not a Hash' do
      expect { subject.send(:validate_params, 'not_a_hash') }
        .to raise_error(ArgumentError, /`params` is expected to be a Hash/)
    end

    it 'does not raise ArgumentError when params is a Hash' do
      expect { subject.send(:validate_params, { key: 'value' }) }.not_to raise_error
    end

    it 'does not raise ArgumentError when params is an empty Hash' do
      expect { subject.send(:validate_params, {}) }.not_to raise_error
    end
  end

  describe '#authenticator' do
    it 'returns an instance of OAuth2::Authenticator' do
      expect(subject.send(:authenticator)).to be_an_instance_of(OAuth2::Authenticator)
    end

    it 'passes the correct arguments to the Authenticator constructor' do
      authenticator = instance_double(OAuth2::Authenticator)
      expect(OAuth2::Authenticator).to receive(:new)
        .with(client_id, client_secret, authentication_scheme)
        .and_return(authenticator)
      expect(subject.send(:authenticator)).to eq(authenticator)
    end
  end

  describe '#redirect_uri' do
    it { expect(subject.send(:redirect_uri)).to eq(subject.options[:redirect_uri]) }
  end

  describe '#authorize_options_url' do
    it do
      expect(subject.send(:authorize_options_url))
        .to eq(subject.options[:authorize_options][:url])
    end
  end

  describe '#token_options_method' do
    it do
      expect(subject.send(:token_options_method))
        .to eq(subject.options[:token_options][:method])
    end
  end

  describe '#token_options_url' do
    it do
      expect(subject.send(:token_options_url))
        .to eq(subject.options[:token_options][:url])
    end
  end

  describe '#token_options_headers' do
    it do
      expect(subject.send(:token_options_headers))
        .to eq(subject.options[:token_options][:headers])
    end
  end

  describe '#redirect_uri_params' do
    let(:redirect_uri_params) { { redirect_uri: subject.options[:redirect_uri] } }

    it { expect(subject.send(:redirect_uri_params)).to eq(redirect_uri_params) }

    it 'empty hash when unless redirect_uri options' do
      subject.options.delete(:redirect_uri)

      expect(subject.send(:redirect_uri_params)).to eq({})
    end
  end

  describe '#merge_base_and_transform_params' do
    let(:code) { '12345' }
    let(:params) { { 'code' => code } }
    let(:merge_base_and_transform_params) do
      redirect_uri_params
        .merge(params.transform_keys(&:to_sym))
        .transform_keys(&:to_s)
    end

    it 'returns a redirect_uri and params Hash with stringify hash keys' do
      expect(subject.send(:merge_base_and_transform_params, params)).to eq(merge_base_and_transform_params)
    end

    it 'returns only params with stringify hash keys when does not present redirect_uri' do
      subject.options.delete(:redirect_uri)

      expect(subject.send(:merge_base_and_transform_params, params)).to eq(params.transform_keys(&:to_s))
    end
  end

  describe '#build_authorize_params' do
    let(:params) { { scope: 'read', response_type: 'code' } }
    let(:response) { { 'redirect_uri' => callback_uri, 'scope' => 'read', 'response_type' => 'code' } }

    it 'merges and transforms the params correctly' do
      expect(subject.send(:build_authorize_params, params)).to eq(response)
    end
  end

  describe '#build_token_request_options' do
    let(:code) { '12345' }
    let(:params) { { code: code } }
    let(:build_params) do
      redirect_uri_params.merge(params.transform_keys(&:to_s)).transform_keys(&:to_s)
    end
    let(:build_headers) do
      OAuth2::Authenticator
        .new(client_id, client_secret, authentication_scheme)
        .apply!(build_params, token_options[:headers])
    end
    let(:build_token_request_options) do
      {
        method: token_options[:method],
        url: token_options[:url],
        body: build_params,
        headers: build_headers
      }
    end

    before do
      allow_any_instance_of(OAuth2::Authenticator).to receive(:basic_auth_header)
        .and_return(token_options[:headers].merge('Authorization' => 'Basic Auth'))
    end

    it 'returns defaults options without options args' do
      expect(subject.send(:build_token_request_options, params)).to eq(build_token_request_options)
      expect(subject.send(:build_token_request_options, params).keys).to all(be_a(Symbol))
      expect(subject.send(:build_token_request_options, params)[:body].keys).to all(be_a(String))
    end
  end

  describe '#request' do
    let(:method) { :post }
    let(:url) { 'http://example.com/' }
    let(:body) { URI.encode_www_form({ 'param_1' => 'value_1' }) }
    let(:headers) { { 'Content-Type' => 'application/json' } }

    it 'returns an object of AccessTokenResponse when request is successful' do
      mock_response =
        instance_double(Faraday::Response, body: { token: 'Token' }.to_json, status: 200)

      allow(subject.connection).to receive(:run_request).and_return(mock_response)

      response = subject.send(:request, method, url, body, headers)

      expect(response).to be_instance_of(OAuth2::Client::Response)
      expect(response.status).to eq(200)
      expect(response.body).to have_key('token')
      expect(response.body['token']).to eq('Token')
    end

    context 'when return Connection Errors' do
      before  { allow(subject.connection).to receive(:run_request).and_raise(faraday_exception) }

      shared_examples 'failed connection handler' do
        it 'rescues the exception' do
          expect { subject.send(:request, method, url, body, headers) }
            .to raise_error do |e|
              expect(e.message).to eq(faraday_exception.message)
              expect(e.class).to eq(expected_exception)
            end
        end
      end

      context 'returns an Faraday::ConnectionFailed' do
        let(:faraday_exception) { Faraday::ConnectionFailed.new('fail') }
        let(:expected_exception) { OAuth2::ConnectionError }

        it_behaves_like 'failed connection handler'
      end

      context 'returns an Faraday::TimeoutError' do
        let(:faraday_exception) { Faraday::TimeoutError.new('timeout') }
        let(:expected_exception) { OAuth2::TimeoutError }

        it_behaves_like 'failed connection handler'
      end
    end
  end

  context "handle_response_body" do
    it "parses JSON response body" do
      response_body = { "key" => "value" }.to_json

      parsed_body = subject.send(:handle_response_body, response_body)

      expect(parsed_body).to eq({ "key" => "value" })
    end

    it "returns the original body if it's not a string" do
      response_body = { "key" => "value" }

      parsed_body = subject.send(:handle_response_body, response_body)

      expect(parsed_body).to eq(response_body)
    end

    it "returns the original body if parsing as JSON fails" do
      response_body = "<html><body>Error</body></html>"

      parsed_body = subject.send(:handle_response_body, response_body)

      expect(parsed_body).to eq(response_body)
    end
  end
end
