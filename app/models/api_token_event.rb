class ApiTokenEvent < ApplicationRecord
  belongs_to :user
  has_many :tweets
end
