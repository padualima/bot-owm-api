# frozen_string_literal: true

require 'json'

module OAuth2
  AccessTokenResponse = Class.new(Struct.new(:status, :body))
  ConnectionError = Class.new(Faraday::ConnectionFailed)
  TimeoutError = Class.new(Faraday::TimeoutError)

  class Client
    GET_TOKEN_ALLOWED_OPTIONS = %i[url body]

    attr_reader :client_id, :client_secret, :url
    attr_accessor :options
    attr_writer :connection

    # @param [String] client_id the provider client_id key
    # @param [String] client_secret the provider client_secret key
    # @param [String] url the host of the provider
    # @param [Symbol] options the options of connection builder
    def initialize(client_id: nil, client_secret: nil, **options)
      opts = Utils.symbolize_hash_keys(options.dup)

      @client_id = client_id
      @client_secret = client_secret
      @url = opts.delete(:url)
      @options = {
        redirect_uri: nil,
        authorize_options: {
          url: 'oauth/authorize'
        },
        token_options: {
          method: :post,
          url: 'oauth/token',
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        },
        logger: ::Logger.new($stdout)
      }.merge(opts)
    end

    def authorize_url(params = {})
      validate_params(params)

      connection.build_url(authorize_options_url, authorize_url_params(params)).to_s
    end

    # @param [Hash] params the necessary parameters to make the get token request
    # @param [Symbol] options allows overriding request options with GET_TOKEN_ALLOWED_OPTIONS
    def get_token(params = {}, **options)
      validate_params(params)
      request(*get_token_options(params, options).keys)
    end

    def connection
      @connection ||= Faraday.new(url) do |client|
        client.request :url_encoded
        client.response :json
        client.adapter Faraday.default_adapter
      end
    end

    private

    def validate_params(params = {})
      raise ArgumentError, '`params` is expected to be a Hash' unless params.is_a?(Hash)
    end

    def redirect_uri = options[:redirect_uri]

    def authorize_options_url = options[:authorize_options][:url]

    def token_options_method = options[:token_options][:method]

    def token_options_url = options[:token_options][:url]

    def token_options_headers = options[:token_options][:headers]

    def redirect_uri_params = redirect_uri.present? ? { redirect_uri: redirect_uri } : {}

    def authorize_url_params(params = {})
      redirect_uri_params
        .merge(Utils.symbolize_hash_keys(params))
        .then { |params| Utils.stringify_hash_keys(params) }
    end

    def get_token_options(params = {}, options = {})
      {
        method: token_options_method,
        url: token_options_url,
        body: params,
        headers: token_options_headers
      }
        .merge(Utils.filter_hash_by_keys(options, GET_TOKEN_ALLOWED_OPTIONS))
        .tap { |opts| opts[:body] = Utils.stringify_hash_keys(opts[:body]) }
    end

    def request(method, url, body, headers)
      response = run_request(method, url, body, headers)

      return response unless response&.status&.in?(200..599)

      AccessTokenResponse.new(status: response.status, body: JSON.parse(response.body))
    end

    def run_request(method, url, body, headers)
      connection.run_request(method, url, body, headers)
    rescue Faraday::ConnectionFailed => e
      raise ConnectionError, e
    rescue Faraday::TimeoutError => e
      raise TimeoutError, e
    end
  end
end
