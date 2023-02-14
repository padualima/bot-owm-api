# frozen_string_literal: true

class Twitter::PublishTweet < ::Micro::Case
  attribute :access_token, default: -> value { value.to_s.strip }
  attribute :text, default: -> value { value.to_s.strip }

  def call!
    res = Clients::Twitter::V2::Tweets::ManageTweets
      .new(oauth_token: access_token)
      .new_tweet(text)

    return Success result: res.body if res.status.eql?(201)

    Failure result: { message: ErrorSerializer.new(res.body['detail'], 422) }
  end
end
