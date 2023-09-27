# frozen_string_literal: true

FactoryBot.define do
  factory :tweet do
    api_key factory: :api_key
    user { self.api_key.user }
    uid { SecureRandom.rand(100000..900000).to_s }
    text { |n| "This is text #{n.uid}"}
  end
end
