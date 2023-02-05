FactoryBot.define do
  factory :api_token_event do
    user { nil }
    token_type { 1 }
    expires_in { "2023-01-25 01:09:03" }
    access_token { "MyString" }
    scope { "MyString" }
    refresh_token { "MyString" }
  end
end
