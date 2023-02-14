# frozen_string_literal: true

require_relative 'v2/base'
require_relative 'utils'

module Clients
  module Twitter
    class OAuth2 < V2::Base
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
        .then { |params| "#{ENV['TWITTER_AUTHORIZE_URL']}?#{params}" }
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

      private

      def code_verifier = @code_verifier ||= PKCE.code_verifier

      def code_challenge = PKCE.code_challenge(code_verifier)

      def basic_token = Base64.urlsafe_encode64("#{client_id}:#{client_secret}")
    end
  end
end
