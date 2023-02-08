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
end
