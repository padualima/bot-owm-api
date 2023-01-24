# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    def authorize
      authorize_url = Clients::Twitter::OAuth2.new.authorize_url

      render json: { data: { message: authorize_url } }.to_json
    end
  end
end
