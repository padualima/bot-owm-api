# frozen_string_literal: true

module Helpers
  extend self

  def generate_code_verifier = Clients::Twitter::Utils::PKCE.code_verifier

  def generate_code_challenge(code_verifier)
    Clients::Twitter::Utils::PKCE.code_challenge(code_verifier)
  end

  def generate_authorize_url(client_id: ENV['TWITTER_CLIENT_ID'], state:, code_challenge:)
    authorize_url = ENV['TWITTER_AUTHORIZE_URL']
    callback_url = Rails.application.routes.url_helpers.url_for([:callback, provider: :twitter2])
    scopes = Clients::Twitter::V2::Utils.scopes

    "#{authorize_url}?client_id=#{client_id}&redirect_uri=#{callback_url}&state=#{state}&" \
    "code_challenge=#{code_challenge}&scope=#{scopes}&response_type=code&code_challenge_method=S256"
  end
end
