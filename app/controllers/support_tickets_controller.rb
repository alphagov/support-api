class SupportTicketsController < ApplicationController
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

  def support_ticket_attributes
    params.slice(:subject, :description, :tags, :user_agent, :priority, :requester, :collaborators, :custom_fields, :ticket_form_id)
  end
end
