class User < ApplicationRecord
  has_many :api_token_events
  has_many :tweets
end
