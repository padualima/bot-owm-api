# frozen_string_literal: true

require_relative 'utils'

module Clients
  module Twitter
    module V2
      class Base
        include Utils

        attr_reader :client_id, :client_secret

        attr_accessor :oauth_token

        def initialize(oauth_token: nil)
          @client_id = ENV['TWITTER_CLIENT_ID']
          @client_secret = ENV['TWITTER_CLIENT_SECRET']
          @oauth_token = oauth_token
        end

        def call(method:, endpoint:, params: {}, body: {}, extra_headers: {})
          body = body.present? ? body.to_json : nil

          client.params = params
          res = client.public_send(method, endpoint, body, extra_headers)

          OpenStruct.new(status: res.status, body: handle_response_body(res.body))
        end

        private

        def client
          @client ||= Faraday.new(twitter_base_url) do |client|
            client.request :json
            client.response :json
            client.adapter Faraday.default_adapter
            client.headers['Authorization'] = "Bearer #{oauth_token}" if oauth_token.present?
          end
        end

        def handle_response_body(body)
          body unless body.is_a?(String)

          JSON.parse(body)
        rescue
          body
        end
      end
    end
  end
end
