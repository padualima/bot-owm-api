class ApiController < ApplicationController
  def render_json(json = {}, status)
    render json: json, status: status
  end
end
