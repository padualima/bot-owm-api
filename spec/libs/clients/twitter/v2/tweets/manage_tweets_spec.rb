# frozen_string_literal: true

require "clients/twitter/v2/base"
require "clients/twitter/v2/tweets/manage_tweets"
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
        allow_any_instance_of(Faraday::Connection).to receive(:post)
          .and_return(
            instance_double(
              Faraday::Response,
              body: MockTwitterResponse::Tweets.new_tweet_data(text: text),
              status: 200
            )
          )
      end

      it { expect(subject.new_tweet(text).status).to eql(200) }
      it { expect(subject.new_tweet(text).body['data']['text']).to eql(text) }
    end
  end
end
