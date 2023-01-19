require 'faraday'

module Twitter
  module V2
    class Client
      include Utils

      attr_reader :client_id, :client_secret, :oauth_token

      def initialize(options = {})
        options
          .merge!(client_id: ENV['TWITTER_CLIENT_ID'], client_secret: ENV['TWITTER_CLIENT_SECRET'])
        options.each do |key, value|
          instance_variable_set("@#{key}", value)
        end

        yield(self) if block_given?
      end

      private

      def client
        @client ||= Faraday.new(api_endpoint) do |client|
          client.request :json
          client.response :json
          client.adapter Faraday.default_adapter
          client.headers['Authorization'] = "Bearer #{oauth_token}" if oauth_token.present?
        end
      end

      def call(method:, endpoint:, params: {}, body: {}, extra_headers: {})
        client.params = params
        client.public_send(method, endpoint, body.to_json, extra_headers)
      end
    end
  end
end
