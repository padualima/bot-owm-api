# frozen_string_literal: true

class User::RegisterInTwitterCallback < ::Micro::Case
  attribute :state, default: -> value { value.to_s.strip }
  attribute :code, default: -> value { value.to_s.strip }

  def call!
    transaction do
      Twitter::GetAccessToken.call(state:, code:)
        .then do |token|
          return Failure result: token.data if token.failure?

          Success result: { oauth_access_token: token.data }
        end
        .then(apply(:assign_token_and_expires_in))
        .then(apply(:twitter_user_lookup))
        .then(apply(:find_or_initializer_user))
        .then(apply(:user_api_token_creation))
    end
  end

  private

  def assign_token_and_expires_in(oauth_access_token:, **)
    Success(
      result: {
        access_token_data: oauth_access_token.merge(
          'expires_in' => oauth_access_token['expires_in'].minutes.from_now,
          'token' => ApiTokenGenerator.call(oauth_access_token['access_token'])
        )
      }
    )
  end

  def twitter_user_lookup(access_token_data:, **)
    user_info = Twitter::GetUserLookup .call(access_token_data)

    return Failure result: user_info.data if user_info.failure?

    user_info.data['data']['uid'] = user_info.data['data'].delete('id')

    Success result: { user_info: user_info.data['data'] }
  end

  def find_or_initializer_user(user_info:, **)
    Success result: { user: User.find_by(uid: user_info['uid']) || User.new(user_info) }
  end

  def user_api_token_creation(access_token_data:, user:, **)
    user.latest_valid_api_token&.update!(expires_in: Time.current)

    api_token = user.api_token_events.new(access_token_data)

    return Success :api_token_valid, result: { api_token: api_token } if api_token.save!

    Failure :api_token_invalid, result: { message: api_token.errors.full_messages }
  end
end
