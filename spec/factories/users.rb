# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    uid { Faker::Number.number.to_s }
    name { Faker::Name.name }
    username { Faker::Internet.user_name }
  end
end
