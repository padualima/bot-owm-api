class ApiKey < ApplicationRecord
  belongs_to :user
  has_many :tweets

  validates :token_type, :expires_in, :access_token, :scope, :token, presence: true
  validates :access_token, :refresh_token, :token, uniqueness: true
  validate :check_if_expired, if: -> { expires_in.present? }

  scope :by_valid, -> { where('expires_in > ?', Time.current) }

  def check_if_expired
    errors.add(:expires_in, "expiration date not allowed") if expired?
  end

  def expired?
    expires_in < Time.current
  end
end
