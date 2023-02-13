# frozen_string_literal: true

class ApiController < ApplicationController
  def render_json(json = {}, status= :ok)
    render json: json, status: status
  end
end
