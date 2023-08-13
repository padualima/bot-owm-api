# frozen_string_literal: true

module MockTwitterResponse
  module OAuth2
    extend self

    def access_token_data(access_token: SecureRandom.hex(10))
      {
        token_type: "bearer",
        expires_in: 7200,
        access_token: access_token,
        scope: "tweet.write users.read tweet.read offline.access",
        refresh_token: SecureRandom.hex(10)
      }.to_json
    end
  end

  module Users
    extend self

    def me_data(id: SecureRandom.rand(10000..20000))
      {
        data: {
          id: id,
          name: Faker::Name.name,
          username: Faker::Internet.username(specifier: 5..10)
        }
      }.to_json
    end
  end

  module Tweets
    extend self

    def tweet_published_data(text: Faker::Lorem.sentence)
      {
        data: {
          edit_history_tweet_ids: [SecureRandom.rand(100000..900000).to_s],
          id: SecureRandom.rand(100000..900000).to_s,
          text: text
        }
      }.as_json
    end
  end
end
