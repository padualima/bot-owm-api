# frozen_string_literal: true
require "clients/twitter/v2/base"
require "clients/twitter/v2/tweets/manage_tweets"
require 'rails_helper'

describe ::Clients::Twitter::V2::Tweets::ManageTweets do
  describe "#new_tweet" do
    context "when invalid argument text" do
      it "return nil"
    end

    context "when valid argument text" do
      it "return success"
    end
  end
end
