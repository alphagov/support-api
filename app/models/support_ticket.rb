class SupportTicket
  include ActiveModel::Validations

  validates :subject, :description, presence: true

  def initialize(attributes)
    @subject = attributes.fetch(:subject, nil)
    @tags = attributes.fetch(:tags, nil)
    @description = attributes.fetch(:description, nil)
  end

  def zendesk_ticket_attributes
    {
      "subject" => subject,
      "tags" => tags,
      "comment" => {
        "body" => description,
      },
    }
  end

private

  attr_reader :subject, :tags, :description
end
