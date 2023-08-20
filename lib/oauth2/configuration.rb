# frozen_string_literal: true

require 'singleton'

module OAuth2
  class Configuration
    include Singleton
    attr_reader :providers

    def initialize
      @providers = {}
    end
  end
end
