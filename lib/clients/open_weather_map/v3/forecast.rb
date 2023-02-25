# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    module V3
      class Forecast
        attr_accessor :lat, :lon, :lang, :units, :strategy, :cnt

        def self.current(*options)
          new(*options).current
        end

        def initialize(options={})
          options.each do |key, value|
            instance_variable_set("@#{key}", value)
          end

          yield(self) if block_given?
        end

        def lang = @lang ||= 'pt'

        def units = @units ||= "metric"

        def strategy = @strategy ||= "daily"

        def cnt = @cnt ||= '4'

        def current
          body = { lat: lat, lon: lon, lang: lang, units: units, cnt: cnt }

          Base.call(method: :get, endpoint: endpoint, body: body)
        end

        private

        def endpoint
          if strategy == 'daily'
            'data/2.5/forecast/daily'
          elsif strategy == 'hourly'
            'data/2.5/forecast/hourly'
          end
        end
      end
    end
  end
end
