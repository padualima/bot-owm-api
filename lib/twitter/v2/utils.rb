module Twitter
  module V2
    module Utils
      def api_endpoint
        @api_endpoint ||= "https://api.twitter.com/2".freeze
      end

      def callback_url
        @callback_url ||= ENV['TWITTER_CALLBACK_URL']
      end
    end
  end
end
