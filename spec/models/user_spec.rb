# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context "relations" do
    it { should have_many(:api_keys) }
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

  describe "#latest_valid_api_key" do
    let(:api_key) { create(:api_key) }

    subject { api_key.user }

    context "when has a valid token" do
      it "return the latest valid api token" do
        expect(subject.latest_valid_api_key).to eql(api_key)
      end
    end

    context "when has not a valid token" do
      before do
        api_key.update_columns(expires_in: Time.current)
      end

      it "return nil object" do
        expect(subject.latest_valid_api_key).to eql(nil)
      end
    end

    context "when has not valid tokens" do
      subject { create(:user) }

      it "return nil object" do
        expect(subject.latest_valid_api_key).to eql(nil)
      end
    end
  end
end
