require "erb"

module Zendesk
  class Ticket
    def initialize(contact)
      @contact = contact
    end

    def attributes
      {
        subject:,
        requester: { "locale_id" => 1, "email" => requester[:email], "name" => requester[:name] },
        collaborators: collaborator_emails,
        tags:,
        comment: { "body" => rendered_body },
      }
    end

  private

    def rendered_body
      path_to_template = Rails.root.join("app/zendesk_tickets/#{template_name}.erb")
      template = ERB.new(File.read(path_to_template))
      template.result(binding)
    end

    def collaborator_emails
      []
    end
  end
end
