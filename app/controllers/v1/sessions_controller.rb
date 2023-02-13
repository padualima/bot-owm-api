# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    def authorize
      authorize_url = Clients::Twitter::OAuth2.new.authorize_url

      render json: { data: { message: authorize_url } }.to_json
    end

    def callback
      oauth = oauth_access_token(params[:state], params[:code])

      unless oauth.status.eql?(200)
        return render_json(
          ErrorSerializer.new("Twitter Authentication Failed", 422),
          :unprocessable_entity
        )
      end

      ActiveRecord::Base.transaction do
        oauth.body.merge!(
          'expires_in' => oauth.body['expires_in'].minutes.from_now,
          'token' => ApiTokenGenerator.call(oauth.body['access_token'])
        )

        user_lookup_data(oauth.body['access_token'])
          .then do |user_info|
            input = user_info.body['data'].merge('uid' => user_info.body['data'].delete('id'))
            User.find_by(uid: input['uid']) || User.new(input)
          end
          .then do |user|
            user.latest_valid_api_token&.update!(expires_in: Time.current)
            user.api_token_events.new(oauth.body)
          end
          .then do |user_api_token|
            if user_api_token.save!
              render_json({ data: [{ users: { token: user_api_token.token } }] })
            end
          end
      end
    end

    private

    def oauth_access_token(state, code)
      Clients::Twitter::OAuth2.new.access_token(state, code)
    end

    def user_lookup_data(access_token)
      Clients::Twitter::V2::Users::Lookup.new(oauth_token: access_token).me
    end
  end
end
