# frozen_string_literal: true

module OAuth2
  class Client
    attr_reader :client_id, :client_secret, :url
    attr_accessor :options
    attr_writer :connection

    # @param [String] client_id the provider client_id key
    # @param [String] client_secret the provider client_secret key
    # @param [String] url the host of the provider
    # @param [String] options the options of connection builder
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
      raise ArgumentError, '`params` is expected to be a Hash' unless params.is_a?(Hash)

      connection.build_url(options[:authorize_url], authorize_url_params(params)).to_s
    end

    def connection
      @connection ||= Faraday.new(url) do |client|
        client.request :url_encoded
        client.response :json
        client.adapter Faraday.default_adapter
      end
    end

    private

    def redirect_uri
      options[:redirect_uri]
    end

    def redirect_uri_params
      redirect_uri.present? ? { redirect_uri: redirect_uri } : {}
    end

    def authorize_url_params(params)
      redirect_uri_params.then { |param| param.merge(params.transform_keys(&:to_sym)) }
    end
  end
end
