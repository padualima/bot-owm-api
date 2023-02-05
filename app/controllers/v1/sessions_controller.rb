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

      expires_in = oauth.body['expires_in'].minutes.from_now

      token = ActiveRecord::Base.transaction do
        api_token_input =
          oauth.body.merge(expires_in: expires_in, token: ApiTokenEvent.token_generator)

        user_api_token = User
          .new(user_lookup_data(oauth.body['access_token']))
          .then { |user| user.api_token_events.new(api_token_input) }
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
