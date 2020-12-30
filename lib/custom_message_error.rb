# frozen_string_literal: true

class CustomMessageError < StandardError
  attr_reader :message, :status

  def initialize(status, message)
    @status = status
    @message = message
  end
end
