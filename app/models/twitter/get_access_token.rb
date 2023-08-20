# frozen_string_literal: true

class Twitter::GetAccessToken < ::Micro::Case
  attribute :state, default: -> value { value.to_s.strip }
  attribute :code, default: -> value { value.to_s.strip }

  def call!
    res = OAuth2::Twitter.access_token(state, code)

    return Success result: res.body if res.status.eql?(200)

    message = ErrorSerializer.new(res.body, 422)

    Failure :oauth_failed, result: { message: message }
  end
end
