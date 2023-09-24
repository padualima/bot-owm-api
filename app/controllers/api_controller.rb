# frozen_string_literal: true

class ApiController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!

  def render_json(json = {}, status= :ok)
    render json: json, status: status
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    render json: ErrorSerializer.new(exception.message, 401), status: :unauthorized
  end

  protected

  def authenticate_user!
    return current_user if api_token && api_token.valid?

    raise Pundit::NotAuthorizedError, 'Access Unauthorized'
  end

  def current_user
    @current_user = api_token.user
  end

  # TODO: change api_token method to api_key
  def api_token
    token =
      if request.headers['Authorization']
        request.headers['Authorization'].split.last
      else
        params[:api_key] || params[:token]
      end

    # TODO: remove params[:token] in future and change variable @api_token to @api_key
    @api_token = ApiTokenEvent
      .by_valid
      .find_by(token: token)
  end
end
