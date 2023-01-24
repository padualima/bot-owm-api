# frozen_string_literal: true
require_relative 'v2/base'
require_relative 'utils'

module Clients
  module Twitter
    class OAuth2 < V2::Base

      attr_reader :code_verifier, :code_challenge

      include Utils

      def authorize_url
        params = {
          client_id: client_id,
          redirect_uri: callback_url,
          state: code_verifier,
          code_challenge: code_challenge,
          scope: scopes,
          response_type: 'code',
          code_challenge_method: "S256"
        }
        .map { |k,v| [k,v].join('=') }
        .join('&')

        ["https://twitter.com/i/oauth2/authorize", params].join('?')
      end

      def code_verifier
        @code_verifier ||= PKCE.code_verifier
      end

      def code_challenge
        @code_challenge ||= PKCE.code_challenge
      end
    end
  end
end
