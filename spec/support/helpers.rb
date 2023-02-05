# frozen_string_literal: true

module Helpers
  def generate_code_verifier
    Clients::Twitter::Utils::PKCE.code_verifier
  end
  module_function :generate_code_verifier

  def generate_code_challenge(code_verifier)
    Clients::Twitter::Utils::PKCE.code_challenge(code_verifier)
  end
  module_function :generate_code_challenge

  def generate_authorize_url(client_id=ENV['TWITTER_CLIENT_ID'], state, code_challenge)
    "https://twitter.com/i/oauth2/authorize?client_id=#{client_id}&redirect_uri=http://127.0.0.1:" \
    "3000/auths/twitter2/callback&state=#{state}&code_challenge=#{code_challenge}&scope=tweet." \
    "read+users.read+tweet.write+offline.access&response_type=code&code_challenge_method=S256"
  end
  module_function :generate_authorize_url

  def access_token_response
    {
      token_type: "bearer",
      expires_in: 7200,
      access_token: SecureRandom.hex(10),
      scope: "tweet.write users.read tweet.read offline.access",
      refresh_token: SecureRandom.hex(10)
    }.as_json
  end
  module_function :access_token_response


  def me_response
    {
      data: {
        id: SecureRandom.rand(10000..20000),
        name: Faker::Name.name,
        username: Faker::Internet.username(specifier: 5..10)
      }
    }.as_json
  end
  module_function :me_response
end
