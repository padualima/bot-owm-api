class User < ApplicationRecord
  has_many :api_token_events
  has_many :tweets

  validates :uid, :name, :username, presence: true
  validates :uid, uniqueness: { case_sensitive: false }
  validates :username, uniqueness: true
  validates :uid, format: { with: /\A\d+\d\z/ }

  def latest_valid_api_token
    api_token_events.find_by("expires_in > ?", Time.current)
  end
end
