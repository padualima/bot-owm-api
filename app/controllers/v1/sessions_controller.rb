# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    def authorize
      render json: { data: { message: OAuth2::Twitter.authorize_url } }.to_json
    end

    def callback
      User::RegisterInTwitterCallback
        .call(callback_params.to_h)
        .on_failure { |result| render_json(result[:message], :unprocessable_entity) }
        .on_success { |result| render_json({ users: { token: result.data[:api_token].token } }) }
    end

    private

    def callback_params
      params.permit(:state, :code)
    end
  end
end
