# frozen_string_literal: true

class Twitter::GetAccessToken < ::Micro::Case
  attribute :state, default: -> value { value.to_s.strip }
  attribute :code, default: -> value { value.to_s.strip }
  attribute :redirect_uri, default: -> value { value.to_s.strip }

  def call!
    options = {}
    options[:redirect_uri] = redirect_uri unless redirect_uri.blank?

    res = OAuth2::Twitter.access_token(state, code, **options)

    return Success result: res.body if res.status.eql?(200)

    message = ErrorSerializer.new(res.body, 422)

    Failure :oauth_failed, result: { message: message }
  end
end
