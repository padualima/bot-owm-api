class ApiTokenEvent < ApplicationRecord

  belongs_to :user
  has_many :tweets

  validates :token_type, :expires_in, :access_token, :scope, :token, presence: true
  validates :access_token, :refresh_token, :token, uniqueness: true
end
