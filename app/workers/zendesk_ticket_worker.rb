class ZendeskTicketWorker
  include Sidekiq::Worker

  def perform(ticket_attributes)
    GDS_ZENDESK_CLIENT.ticket.create!(HashWithIndifferentAccess.new(ticket_attributes))
  end
end
