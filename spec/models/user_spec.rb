# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context "relations" do
    it { should have_many(:api_token_events) }
    it { should have_many(:tweets) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:uid) }
    it { should validate_uniqueness_of(:uid).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }

    it { should_not allow_value(Faker::Internet.uuid).for(:uid) }
    it { should allow_value(Faker::Number.number.to_s).for(:uid) }
    it { should allow_value(Faker::Number.number).for(:uid) }
  end

  describe "#latest_valid_api_token" do
    let(:api_token_event) { create(:api_token_event) }

    subject { api_token_event.user }

    context "when has a valid token" do
      it "return the latest valid api token" do
        expect(subject.latest_valid_api_token).to eql(api_token_event)
      end
    end

    context "when has not a valid token" do
      before do
        api_token_event.update(expires_in: Time.current)
      end

      it "return nil object" do
        expect(subject.latest_valid_api_token).to eql(nil)
      end
    end

    context "when has not valid tokens" do
      subject { create(:user) }

      it "return nil object" do
        expect(subject.latest_valid_api_token).to eql(nil)
      end
    end
  end
end
