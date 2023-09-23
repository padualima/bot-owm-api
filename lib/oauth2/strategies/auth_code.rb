# frozen_string_literal: true

require_relative 'base'
require 'oauth2/client'

module OAuth2
  module Strategies
    class AuthCode < Base
      def authorize_url(**params)
        validate_params(params, 'client_secret')

        # By default, `client` adds redirect_uri to params. Will be replaced if present in params
        client.authorize_url(params.merge(response_type: 'code', client_id: client.id).dup)
      end

      def get_token(code, **params)
        validate_params(params)

        # By default, `client` adds redirect_uri to params. Will be replaced if present in params
        client.get_token(params.merge(grant_type: 'authorization_code', code: code).dup)
      end

      private

      def validate_params(params = {}, disallowed_param = nil)
        raise ArgumentError, '`params` is expected to be a Hash' unless params.is_a?(Hash)

        return unless params.key?(disallowed_param&.to_sym) || params.key?(disallowed_param.to_s)

        raise ArgumentError, "#{disallowed_param} is not allowed params"
      end
    end
  end
end
