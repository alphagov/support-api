class SupportTicketsController < ApplicationController
  def create
    support_ticket = SupportTicket.new(attributes)

    if support_ticket.valid?
      GDS_ZENDESK_CLIENT.ticket.create!(support_ticket.attributes)

      render json: { status: "success" }, status: :created
    else
      render json: { status: "error", errors: support_ticket.errors }, status: :unprocessable_entity
    end
  end

private

  def attributes
    params.slice(:subject, :tags, :user_agent, :description)
  end
end
