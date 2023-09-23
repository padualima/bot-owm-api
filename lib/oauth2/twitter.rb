# frozen_string_literal: true

require 'oauth2/strategies/auth_code'
require 'oauth2/client'
require 'oauth2/pkce_generator'
require 'oauth2/utils'

module OAuth2
  module Twitter
    extend self

    def authorize_url(**options)
      strategy
        .authorize_url(
          state: code_verifier,
          code_challenge: code_challenge,
          scope: scopes,
          code_challenge_method: 'S256',
          **options
        )
    end

    def access_token(state, code, **options)
      strategy.get_token(code, code_verifier: state, client_id: client.id, **options)
    end

    private

    def client = Utils.build_oauth2_client(:twitter)

    def strategy = client.auth_code

    def code_verifier = @code_verifier ||= PKCEGenerator.code_verifier

    def code_challenge = PKCEGenerator.code_challenge(code_verifier)

    def scopes = ENV['TWITTER_SCOPES_AUTH']
  end
end
