class SupportTicketsController < ApplicationController
  def create
    support_ticket = SupportTicket.new(support_ticket_attributes)

    if support_ticket.valid?
      pp support_ticket.zendesk_ticket_attributes

      ## TODO Handle Zendesk client's errors
      response = GDS_ZENDESK_CLIENT.ticket.create!(support_ticket.zendesk_ticket_attributes)
      pp response 
      
      render json: { status: "success" }, status: :created
    else
      render json: { status: "error", errors: support_ticket.errors }, status: :unprocessable_entity
    end
  end

private

  def support_ticket_attributes
    params.slice(
      :subject, :description, :tags, :priority, :requester, :collaborators, :custom_fields, :ticket_form_id
    ).permit(
      :subject, :description, :tags, :priority, :collaborators, :ticket_form_id,
      requester: [:locale_id, :email, :name],
      custom_fields: [:id, :value]
    )
  end
end
