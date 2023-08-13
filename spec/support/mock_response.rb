# frozen_string_literal: true

module MockResponse
  module Twitter
    module OAuth2
      extend self

      def access_token_data(access_token: SecureRandom.hex(10), status: 200)
        {
          status: status,
          body: {
            token_type: "bearer",
            expires_in: 7200,
            access_token: access_token,
            scope: "tweet.write users.read tweet.read offline.access",
            refresh_token: SecureRandom.hex(10)
          }.to_json
        }
      end
    end

    module Users
      extend self

      def me_data(id: SecureRandom.rand(10000..20000), status: 200)
        {
          status: status,
          body: {
            data: {
              id: id,
              name: Faker::Name.name,
              username: Faker::Internet.username(specifier: 5..10)
            }
          }.to_json
        }
      end
    end
  end
end
