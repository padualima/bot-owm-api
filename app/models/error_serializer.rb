# frozen_string_literal: true

class ErrorSerializer
  def initialize(message, status)
    @message = message
    @status = status
  end

  FriendlyMessage = -> data do
    return data.join if data.one?

    data.take(data.count-1).join(", ") << " and #{data.last}"
  end

  def to_json(*)
    { errors: [ status: @status, detail: FriendlyMessage.call(Array(@message)) ] }.to_json
  end
end
