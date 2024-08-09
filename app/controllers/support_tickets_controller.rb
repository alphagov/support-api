class SupportTicketsController < ApplicationController
  rescue_from ZendeskAPI::Error::RecordInvalid, with: :handle_as_validation_error

  rescue_from ZendeskAPI::Error::NetworkError, with: :cast_zendesk_api_error

  def create
    support_ticket = SupportTicket.new(support_ticket_attributes)

    if support_ticket.valid?
      GDS_ZENDESK_CLIENT.ticket.create!(support_ticket.zendesk_ticket_attributes)

      render json: { status: "success" }, status: :created
    else
      render json: { status: "error", errors: support_ticket.errors }, status: :unprocessable_entity
    end
  end

private

  def handle_as_validation_error(error)
    render json: { status: "error", errors: error.message }, status: :unprocessable_entity
  end

  def cast_zendesk_api_error(error)
    render json: { status: "error", errors: error.message }, status: error.response[:status]
  end

  def support_ticket_attributes
    params.slice(
      :subject, :description, :priority, :requester, :collaborators, :tags, :custom_fields, :ticket_form_id
    ).permit(
      :subject, :description, :priority, :ticket_form_id,
      requester: %i[locale_id email name],
      collaborators: [],
      tags: [],
      custom_fields: %i[id value]
    )
  end
end
