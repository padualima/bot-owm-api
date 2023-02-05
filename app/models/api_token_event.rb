class ApiTokenEvent < ApplicationRecord
  belongs_to :user
  has_many :tweets

  def self.token_generator
    SecureRandom.urlsafe_base64(64, false)
  end
end
