# frozen_string_literal: true

class DraftSupportRequestsController < ApplicationController
  def show
    draft_support_request = DraftSupportRequest.find_by(support_app_reference:)

    if draft_support_request.present?
      render json: draft_support_request, status: :ok
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def update
    draft_support_request = DraftSupportRequest.find_or_create_by!(support_app_reference:)

    if draft_support_request.update(draft_support_request_attributes)
      render json: draft_support_request, status: :ok
    else
      render json: { errors: draft_support_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

private

  def support_app_reference
    params.expect(:support_app_reference)
  end

  def draft_support_request_attributes
    params.expect(draft_support_request: {})
  end
end
