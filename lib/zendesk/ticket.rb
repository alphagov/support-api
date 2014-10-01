require 'erb'
require 'gds_zendesk/field_mappings'

module Zendesk
  class Ticket
    def initialize(contact)
      @contact = contact
    end

    def attributes
      {
        subject: subject,
        requester: { "locale_id" => 1, "email" => requester[:email], "name" => requester[:name] },
        collaborators: collaborator_emails,
        fields: [
                  { "id" => GDSZendesk::FIELD_MAPPINGS[:needed_by_date],  "value" => needed_by_date },
                  { "id" => GDSZendesk::FIELD_MAPPINGS[:not_before_date], "value" => not_before_date }
                ],
        tags: tags,
        comment: { "body" => rendered_body }
      }
    end

  private
    def rendered_body
      path_to_template = File.join(Rails.root, 'app', 'zendesk_tickets', "#{template_name}.erb")
      template = ERB.new(File.read(path_to_template))
      template.result(binding)
    end

    def needed_by_date
      nil
    end

    def not_before_date
      nil
    end

    def collaborator_emails
      []
    end
  end
end
