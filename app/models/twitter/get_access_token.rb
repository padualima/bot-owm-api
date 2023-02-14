# frozen_string_literal: true

class Twitter::GetAccessToken < ::Micro::Case
  attribute :state, default: -> value { value.to_s.strip }
  attribute :code, default: -> value { value.to_s.strip }

  def call!
    res = Clients::Twitter::OAuth2.new.access_token(state, code)

    return Success result: res.body if res.status.eql?(200)

    message = ErrorSerializer.new(res.body['error_description'], 422)

    Failure :oauth_failed, result: { message: message }
  end
end
