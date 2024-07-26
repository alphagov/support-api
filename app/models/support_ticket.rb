class SupportTicket
  include ActiveModel::Validations

  validates :subject, :description, presence: true

  def initialize(attributes)
    @subject = attributes.fetch(:subject, nil)
    @description = attributes.fetch(:description, nil)
    @priority = attributes.fetch(:priority, nil)
    @requester = attributes.fetch(:requester, nil)
    @collaborators = attributes.fetch(:collaborators, nil)
    @tags = attributes.fetch(:tags, nil)
    @custom_fields = attributes.fetch(:custom_fields, nil)
    @ticket_form_id = attributes.fetch(:ticket_form_id, nil)
  end

  def zendesk_ticket_attributes
    {
      "subject" => subject,
      "comment" => { "body" => description },
      "priority" => priority,
      "requester" => requester,
      "collaborators" => collaborators,
      "tags" => tags,
      "custom_fields" => custom_fields,
      "ticket_form_id" => ticket_form_id,
    }.compact
  end

private

  attr_reader :subject, :description, :priority, :requester, :collaborators, :tags, :custom_fields, :ticket_form_id
end
