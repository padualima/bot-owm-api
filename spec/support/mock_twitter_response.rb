# frozen_string_literal: true

module MockTwitterResponse
  module OAuth2
    def access_token_data(access_token=SecureRandom.hex(10))
      {
        token_type: "bearer",
        expires_in: 7200,
        access_token: access_token,
        scope: "tweet.write users.read tweet.read offline.access",
        refresh_token: SecureRandom.hex(10)
      }.as_json
    end
    module_function :access_token_data
  end

  module Users
    def me_data(id=SecureRandom.rand(10000..20000))
      {
        data: {
          id: id,
          name: Faker::Name.name,
          username: Faker::Internet.username(specifier: 5..10)
        }
      }.as_json
    end
    module_function :me_data
  end

  module Tweets
    def new_tweet_data(text=Faker::Lorem.sentence)
      {
        "data" => {
          "edit_history_tweet_ids"=>[SecureRandom.rand(100000..900000).to_s],
          "id"=>SecureRandom.rand(100000..900000).to_s,
          "text"=>text
        }
      }
    end
    module_function :new_tweet_data
  end
end