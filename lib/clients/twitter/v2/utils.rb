# frozen_string_literal: true

module Clients
  module Twitter
    module V2
      module Utils
        def twitter_base_url = ENV['TWITTER_BASE_URL_V2']

        def callback_url = ENV['TWITTER_CALLBACK_URL']

        def scopes = ["tweet.read", "users.read", "tweet.write", "offline.access"].join('+')
        module_function :scopes
      end
    end
  end
end
