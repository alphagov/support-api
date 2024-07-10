class SupportTicket
  include ActiveModel::Validations

  validates :subject, :description, presence: true

  def initialize(attributes)
    @subject = attributes.fetch(:subject, nil)
    @priority = attributes.fetch(:priority, nil)
    @requester = attributes.fetch(:requester, nil)
    @collaborators = attributes.fetch(:collaborators, nil)
    @tags = attributes.fetch(:tags, nil)
    @custom_fields = attributes.fetch(:custom_fields, nil)
    @ticket_form_id = attributes.fetch(:ticket_form_id, nil)
    @description = attributes.fetch(:description, nil)
  end

  def zendesk_ticket_attributes
    attr = {
      "subject" => subject,
      "comment" => { "body" => description },
    }

    optional_attributes = {
      "priority" => priority,
      "requester" => requester,
      "collaborators" => collaborators,
      "tags" => tags,
      "custom_fields" => custom_fields,
      "ticket_form_id" => ticket_form_id,
    }

    attr.merge!(optional_attributes.compact)
  end

private

  attr_reader :subject, :description, :user_agent, :priority, :requester, :collaborators, :tags, :custom_fields, :ticket_form_id
end
