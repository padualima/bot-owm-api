# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    module V3
      module Base
        def self.api_key = ENV['OPEN_WEATHER_MAP_API_KEY']

        def self.api_url = ENV['OPEN_WEATHER_MAP_API_URL']

        def self.client
          Faraday.new(api_url) do |client|
            client.request :json
            client.response :json
            client.adapter Faraday.default_adapter
          end
        end

        def self.call(method:, endpoint:, body: {})
          body = body.merge!(appid: api_key).as_json

          client.public_send(method, endpoint, body)
        end
      end
    end
  end
end
