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

      def access_token(state, code)
        call(
          method: :post,
          endpoint: "oauth2/token",
          params: {
            grant_type: "authorization_code",
            code: code,
            code_verifier: state,
            redirect_uri: callback_url,
            client_id: client_id
          },
          extra_headers: {
            "Content-Type"=>"application/x-www-form-urlencoded",
            "Authorization"=> "Basic #{basic_token}"
          }
        )
      end

      def code_verifier
        @code_verifier ||= PKCE.code_verifier
      end

      def code_challenge
        @code_challenge ||= PKCE.code_challenge(code_verifier)
      end

      private

      def basic_token
        Base64.urlsafe_encode64("#{client_id}:#{client_secret}")
      end
    end
  end
end
