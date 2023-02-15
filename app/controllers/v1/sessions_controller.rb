# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    def authorize
      authorize_url = Clients::Twitter::OAuth2.new.authorize_url

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
      params.permit(:state, :code)
    end
  end
end
