class ApiTokenEvent < ApplicationRecord
  before_save :generate_token

  belongs_to :user
  has_many :tweets

  def generate_token
    self.token ||= BCrypt::Password.create(access_token)
  end
end
