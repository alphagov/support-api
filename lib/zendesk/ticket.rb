require "erb"
require "profanity_filter"

module Zendesk
  class Ticket
    class << self
      # Override in subclasses: the contact attributes holding free text
      # from users, masked in the outbound Zendesk ticket. Metadata such
      # as paths, user agent or referrer must never appear here.
      def user_text_fields
        []
      end
    end

    def initialize(contact)
      @contact = contact
      @mask_applied = false
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

    def mask_profanity(text)
      return unless text
      return text unless masking_enabled?

      masked = batch_mask[text]
      return text if masked.nil?

      @mask_applied = true if masked != text
      masked
    end

    def mask_applied?
      @mask_applied
    end

  private

    def masking_enabled?
      ENV.fetch("ZENDESK_PROFANITY_MASKING", "enabled") == "enabled"
    end

    def batch_mask
      @batch_mask ||= begin
        texts = self.class.user_text_fields.filter_map { |field| @contact.public_send(field) }
        texts.zip(ProfanityFilter.mask(texts)).to_h
      end
    end

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
