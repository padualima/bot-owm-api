class User < ApplicationRecord
  has_many :api_token_events
  has_many :tweets

  validates :uid, :name, :username, presence: true
  validates :uid, uniqueness: { case_sensitive: false }, format: { with: /\A\d+\d\z/ }
  validates :username, uniqueness: true

  def latest_valid_api_token
    api_token_events.find_by("expires_in > ?", Time.current)
  end
end
