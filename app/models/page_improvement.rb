class PageImprovement
  include ActiveModel::Validations

  validates_presence_of :description, :url

  def initialize(attributes)
    @url = attributes.fetch(:url, nil)
    @description = attributes.fetch(:description, nil)
    @name = attributes.fetch(:name, nil)
    @email = attributes.fetch(:email, nil)
    @user_agent = attributes.fetch(:user_agent, nil)
  end

  def zendesk_ticket_attributes
    {
      "subject" => url,
      "comment" => {
        "body" => ticket_body
      }
    }
  end

private
  attr_reader :description, :email, :name, :url, :user_agent

  def ticket_body
    <<-TICKET_BODY.strip_heredoc
      [Details]
      #{description}

      [Name]
      #{name}

      [Email]
      #{email}

      [URL]
      #{url}

      [User agent]
      #{user_agent}
    TICKET_BODY
  end
end
