# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    user factory: :user
    token_type { "bearer" }
    expires_in { 7200.minutes.from_now }
    access_token { SecureRandom.hex(10) }
    token { ApiTokenGenerator.call(access_token: self.access_token) }
    scope { "tweet.write users.read tweet.read offline.access" }
    refresh_token { SecureRandom.hex(10) }
  end
end
