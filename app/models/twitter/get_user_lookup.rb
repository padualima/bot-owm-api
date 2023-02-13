# frozen_string_literal: true

class Twitter::GetUserLookup < ::Micro::Case
  attribute :access_token, default: -> value { value.to_s.strip }

  def call!
    res = Clients::Twitter::V2::Users::Lookup.new(oauth_token: access_token).me

    return Success result: res.body if res.status.eql?(200)

    message = ErrorSerializer.new("User Lookup Failed", 422)

    Failure :user_info_failure, result: { message: message }
  end
end
