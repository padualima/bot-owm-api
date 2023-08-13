# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    module V3
      module Base
        extend self

        def api_key = ENV.fetch('OPEN_WEATHER_MAP_API_KEY')

        def api_url = ENV.fetch('OPEN_WEATHER_MAP_API_URL')

        def client
          Faraday.new(api_url) do |client|
            client.request :json
            client.response :json
            client.adapter Faraday.default_adapter
          end
        end

        def call(method:, endpoint:, body: {})
          body = body.merge!(appid: api_key).as_json

          res = client.public_send(method, endpoint, body)

          OpenStruct.new(status: res.status, body: handle_response_body(res.body))
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
