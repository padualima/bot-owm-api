FactoryBot.define do
  factory :tweet do
    uid { "MyString" }
    text { "MyString" }
    api_token_event { nil }
    user { nil }
  end
end
