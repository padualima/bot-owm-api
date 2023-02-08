# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    def authorize
      authorize_url = Clients::Twitter::OAuth2.new.authorize_url

      render json: { data: { message: authorize_url } }.to_json
    end

    def callback
      oauth = Clients::Twitter::OAuth2.new.access_token(params[:state], params[:code])

      return head :unprocessable_entity unless oauth.status.eql?(200)

      input_api_token = oauth.body.merge(
        'expires_in' => oauth.body['expires_in'].minutes.from_now,
        'token' => ApiTokenGenerator.call(oauth.body['access_token'])
      )

      token = ActiveRecord::Base.transaction do
        fetch_user_info = user_lookup_data(input_api_token['access_token'])
        user = User.find_by(uid: fetch_user_info['uid']) || User.new(fetch_user_info)

        user.latest_valid_api_token&.update!(expires_in: Time.current)

        user
          .then { |user| user.api_token_events.new(input_api_token) }
          .then { |user_api_token| user_api_token.token if user_api_token.save! }
      end

      render json: { data: { token: token } }
    end

    private

    def user_lookup_data(access_token)
      Clients::Twitter::V2::Users::Lookup
        .new { |config| config.oauth_token = access_token }
        .me
        .then do |user_info|
          user_info.body['data'].merge('uid' => user_info.body['data'].delete('id'))
        end
    end
  end
end
