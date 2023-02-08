require 'rails_helper'

RSpec.describe ApiTokenEvent, type: :model do
  context "relations" do
    it { should belong_to(:user) }
    it { should have_many(:tweets) }
  end

  describe "validations" do
    subject { build(:api_token_event) }

    it { should validate_presence_of(:token_type) }
    it { should validate_presence_of(:expires_in) }
    it { should validate_presence_of(:access_token) }
    it { should validate_presence_of(:scope) }
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:access_token) }
    it { should validate_uniqueness_of(:refresh_token) }
    it { should validate_uniqueness_of(:token) }
    it { should_not allow_value(Time.current - 1.minute).for(:expires_in) }
    it { should allow_value(Time.current + 1.minute).for(:expires_in) }
  end
end
