class SupportTicket
  include ActiveModel::Validations

  validates :subject, :description, presence: true

  def initialize(attributes)
    @subject = attributes.fetch(:subject, nil)
    @tags = attributes.fetch(:tags, nil)
    @user_agent = attributes.fetch(:user_agent, nil)
    @description = attributes.fetch(:description, nil)
  end

  def attributes
    {
      "subject" => subject,
      "tags" => tags,
      "comment" => {
        "body" => description,
      },
    }
  end

private

  attr_reader :subject, :tags, :user_agent, :description

  def ticket_body
    <<-TICKET_BODY.strip_heredoc
      [User agent]
      #{user_agent}

      [Details]
      #{description}
    TICKET_BODY
  end
end
