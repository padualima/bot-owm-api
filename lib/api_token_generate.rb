class ApiTokenGenerator
  def self.call(*args)
    new(*args).call
  end

  attr_accessor :token

  def initialize(access_token)
    @access_token = access_token
  end

  def call
    token ||= BCrypt::Password.create(@access_token)
  end
end
