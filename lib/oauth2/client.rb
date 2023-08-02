# frozen_string_literal: true

require 'faraday'

module OAuth2
  ConnectionError = Class.new(Faraday::ConnectionFailed)
  TimeoutError = Class.new(Faraday::TimeoutError)

  class Client
    attr_reader :id, :secret, :url
    attr_accessor :options
    attr_writer :connection

    # @param [String] id the provider id key
    # @param [String] secret the provider secret key
    # @param [String] url the host of the provider
    # @param [Symbol] options the options of connection builder
    def initialize(id: nil, secret: nil, **options)
      opts = Utils.symbolize_hash_keys(options.dup)

      @id = id
      @secret = secret
      @url = opts.delete(:url)
      authorize_options = {
        url: 'oauth/authorize'
      }.merge(opts.delete(:authorize_options))
      token_options = {
        method: :post,
        url: 'oauth/token',
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      }.merge(opts.delete(:token_options))
      @options = {
        redirect_uri: nil,
        authentication_scheme: :basic_auth,
        authorize_options: authorize_options,
        token_options: token_options,
        logger: ::Logger.new($stdout)
      }.merge(opts)
    end

    def authorize_url(params = {})
      validate_params(params)

      connection.build_url(authorize_options_url, build_authorize_params(params)).to_s
    end

    # @param [Hash] params the necessary parameters to make the get token request
    # @param [Symbol] options allows overriding request options with GET_TOKEN_ALLOWED_OPTIONS
    def get_token(params = {})
      validate_params(params)

      request(*build_token_request_options(params).values)
    end

    def auth_code
      Strategies::AuthCode.new(self)
    end

    def connection
      @connection ||= Faraday.new(url) do |client|
        client.request :url_encoded
        client.response :json
        client.adapter Faraday.default_adapter
      end
    end

    private

    def authenticator
      Authenticator.new(id, secret, options[:authentication_scheme])
    end

    def validate_params(params = {})
      raise ArgumentError, '`params` is expected to be a Hash' unless params.is_a?(Hash)
    end

    def redirect_uri = options[:redirect_uri]

    def authorize_options_url = options[:authorize_options][:url]

    def token_options_method = options[:token_options][:method]

    def token_options_url = options[:token_options][:url]

    def token_options_headers = options[:token_options][:headers]

    def redirect_uri_params = redirect_uri.present? ? { redirect_uri: redirect_uri } : {}

    def merge_base_and_transform_params(params)
      redirect_uri_params
        .merge(Utils.symbolize_hash_keys(params))
        .then { |params| Utils.stringify_hash_keys(params) }
    end

    def build_authorize_params(params = {})
      merge_base_and_transform_params(params)
    end

    def build_token_request_options(params = {})
      params = merge_base_and_transform_params(params)
      headers = token_options_headers

      authenticator.apply!(params, headers)

      {
        method: token_options_method,
        url: token_options_url,
        body: params,
        headers: headers
      }
    end

    def request(method, url, body, headers)
      connection.run_request(method, url, body, headers)
    rescue Faraday::ConnectionFailed => e
      raise ConnectionError, e
    rescue Faraday::TimeoutError => e
      raise TimeoutError, e
    end
  end
end
