class Tweet < ApplicationRecord
  belongs_to :api_token_event
  belongs_to :user
end
