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
    return current_user if api_key && api_key.valid?

    raise Pundit::NotAuthorizedError, 'Unauthorized Access'
  end

  def current_user
    return unless api_key

    @current_user = api_key.user
  end

  def api_key
    @api_key = ApiKey.by_valid.find_by(token: token_api_key) if token_api_key
  end

  def token_api_key
    request.headers['Authorization'].presence&.split&.last || params[:api_key] || params[:token]
  end
end
