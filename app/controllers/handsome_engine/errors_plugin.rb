# frozen_string_literal: true

module HandsomeEngine::ErrorsPlugin
  extend ActiveSupport::Concern

  included do
    rescue_from CustomMessageError, with: :error_4xx
    rescue_from ActionController::ParameterMissing, with: :error_422
    rescue_from RailsParam::Param::InvalidParameterError, with: :error_422
    rescue_from ActiveRecord::RecordNotFound, with: :handle_404
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_error
    rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_record_error
    rescue_from AASM::InvalidTransition, with: :handle_aasm
  end

  private

  def error_4xx(e)
    render json: { error: e.message }.to_json, status: e.status
  end

  def error_422(e)
    render json: { error: e.message }.to_json, status: :unprocessable_entity
  end
  
  def handle_404(e)
    render json: { error: e.message.presence }, status: :not_found
  end
  
  def handle_aasm(e)
    render json: { error: e.message }.to_json, status: :unprocessable_entity
  end

  def handle_record_error(e)
    error_message = e.record.errors.full_messages.first
    render json: { error: error_message.presence }, status: :unprocessable_entity
  end
end
