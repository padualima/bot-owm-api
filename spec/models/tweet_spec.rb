# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tweet, type: :model do
  context "relations" do
    it { should belong_to(:user) }
    it { should belong_to(:api_key) }
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
    let(:api_key) { build(:api_key) }

    context "when valid token" do
      it { expect(api_key).to be_valid }
    end

    context "when expired token" do
      before do
        api_key.update(expires_in: Time.current)
      end

      it { expect(api_key).not_to be_valid }
    end
  end
end
