# frozen_string_literal: true

require 'rails_helper'

describe Clients::Twitter::V2::Tweets::ManageTweets do
  describe "#new_tweet" do
    context "when invalid argument text" do
      it { expect(subject.new_tweet(nil)).to be nil }
    end

    context "when valid argument text" do
      let(:text) { Faker::Lorem.sentence }
      let(:oauth_token) { SecureRandom.hex(10) }

      subject { ::Clients::Twitter::V2::Tweets::ManageTweets.new(oauth_token: oauth_token) }

      before do
        StubRequest.post(
          url: TWITTER_BASE_URL,
          path: 'tweets',
          response: MockResponse::Twitter::Tweets.tweet_published_data(text: text)
        )
      end

      it { expect(subject.new_tweet(text).status).to eql(201) }
      it { expect(subject.new_tweet(text).body['data']['text']).to eql(text) }
    end
  end
end
