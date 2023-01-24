# frozen_string_literal: true

module Clients
  module Twitter
    module V2
      module Utils
        def domain
          @domain ||= "https://api.twitter.com/2".freeze
        end

        def callback_url
          @callback_url ||= ENV['TWITTER_CALLBACK_URL']
        end

        def scopes
          ["tweet.read", "users.read", "tweet.write", "offline.access"].join('+')
        end
      end
    end
  end
end
