# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tweet, type: :model do
  context "relations" do
    it { should belong_to(:user) }
    it { should belong_to(:api_token_event) }
  end

  describe "validations" do
    subject { build(:tweet) }

    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:uid) }
    it { should validate_uniqueness_of(:uid).case_insensitive }
    it { should_not allow_value(Faker::Internet.uuid).for(:uid) }
    it { should allow_value(Faker::Number.number.to_s).for(:uid) }
    it { should allow_value(Faker::Number.number).for(:uid) }
  end

  describe "#expired?" do
    let(:api_token_event) { build(:api_token_event) }

    context "when valid token" do
      it { expect(api_token_event).to be_valid }
    end

    context "when expired token" do
      before do
        api_token_event.update(expires_in: Time.current)
      end

      it { expect(api_token_event).not_to be_valid }
    end
  end
end
