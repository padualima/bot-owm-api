# frozen_string_literal: true

module Clients
  module Twitter
    module V2
      module Tweets
        class ManageTweets < Base
          def new_tweet(text)
            return unless text

            call(
              method: :post,
              endpoint: "tweets",
              body: { text: text },
              extra_headers: { "Content-Type"=>"application/json" }
            )
          end
        end
      end
    end
  end
end
