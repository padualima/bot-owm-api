# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    module V3
      class Weather
        attr_accessor :lat, :lon, :lang, :units

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

        def current
          body = { lat: lat, lon: lon, lang: lang, units: units }

          Base.call(method: :get, endpoint: 'data/2.5/weather', body: body)
        end
      end
    end
  end
end
