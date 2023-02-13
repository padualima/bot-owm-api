# frozen_string_literal: true

class ErrorSerializer
  def initialize(message, status)
    @message = message
    @status = status
  end

  def to_json(*)
    { errors: [ status: @status, detail: @message ] }.to_json
  end
end
