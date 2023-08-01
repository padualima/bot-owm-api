# frozen_string_literal: true

module OAuth2
  module Strategies
    class Base
      attr_reader :client

      def initialize(client)
        @client = client
      end
    end
  end
end
