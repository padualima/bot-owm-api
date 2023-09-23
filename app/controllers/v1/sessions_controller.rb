# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    def authorize
      authorize_url = OAuth2::Twitter.authorize_url(**authorize_params.to_h)

      render json: { data: { message: authorize_url } }.to_json
    end

    def callback
      User::RegisterInTwitterCallback
        .call(callback_params.to_h)
        .on_failure { |result| render_json(result[:message], :unprocessable_entity) }
        .on_success { |result| render_json({ users: { token: result.data[:api_token].token } }) }
    end

    private

    def callback_params
      params.permit(:state, :code, :redirect_uri)
    end

    def authorize_params
      params.permit(:redirect_uri)
    end
  end
end
