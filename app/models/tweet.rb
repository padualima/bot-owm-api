class Tweet < ApplicationRecord
  belongs_to :api_token_event
  belongs_to :user

  scope :by_user, ->(user) { where(user_id: user.id) }

  validates :uid, :text, presence: true
  validates :uid, uniqueness: { case_sensitive: false }, format: { with: /\A\d+\d\z/ }
end
