class User < ApplicationRecord
  has_many :api_token_events
  has_many :tweets

  validates :uid, :name, :username, presence: true
  validates :uid, uniqueness: { case_sensitive: false }
  validates :username, uniqueness: true
  validates :uid, format: { with: /\A\d+\d\z/ }
end
