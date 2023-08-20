# frozen_string_literal: true

require_relative 'base'
require 'oauth2/client'

module OAuth2
  module Strategies
    class AuthCode < Base
      def authorize_url(**params)
        validate_params(params, 'client_secret')

        client.authorize_url(build_authorize_params(params))
      end

      def get_token(code, **params)
        validate_params(params)

        client.get_token(build_access_token_params(code, params))
      end

      private

      def build_authorize_params(params = {})
        # By default, `client` adds redirect_uri to params. Will be replaced if present in params
        params.merge(response_type: 'code', client_id: client.id).dup
      end

      def build_access_token_params(code = '', params = {})
        # By default, `client` adds redirect_uri to params. Will be replaced if present in params
        params.merge(grant_type: 'authorization_code', code: code).dup
      end

      def validate_params(params = {}, disallowed_param = nil)
        raise ArgumentError, '`params` is expected to be a Hash' unless params.is_a?(Hash)

        return unless params.key?(disallowed_param&.to_sym) || params.key?(disallowed_param.to_s)

        raise ArgumentError, "#{disallowed_param} is not allowed params"
      end
    end
  end
end
