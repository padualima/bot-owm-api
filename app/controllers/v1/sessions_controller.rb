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

      oauth.body.merge!('expires_in' => oauth.body['expires_in'].minutes.from_now)

      token = ActiveRecord::Base.transaction do
        api_token_event = ApiTokenEvent.find_by(access_token:  oauth.body['access_token'])

        user = if api_token_event # add AASM to inactive
          api_token_event.update(expires_in: Time.current)
          api_token_event.user
        else
          User.new(user_lookup_data(oauth.body))
        end

        user
          .then { |user| user.api_token_events.new(oauth.body) }
          .then { |user_api_token| user_api_token.token if user_api_token.save! }
      end

      render json: { data: { token: token } }
    end

    private

    def user_lookup_data(access_token)
      user_info = Clients::Twitter::V2::Users::Lookup
        .new { |config| config.oauth_token = access_token }
        .me

      user_info.body['data']['uid'] = user_info.body['data'].delete('id')
      user_info.body['data']
    end
  end
end
