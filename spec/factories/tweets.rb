# frozen_string_literal: true

FactoryBot.define do
  factory :tweet do
    api_token_event factory: :api_token_event
    user { self.api_token_event.user }
    uid { SecureRandom.rand(100000..900000).to_s }
    text { |n| "This is text #{n.uid}"}
  end
end
