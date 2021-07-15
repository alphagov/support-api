require "zendesk/ticket"

module Zendesk
  class LongFormContactTicket < Ticket
    def subject
      suffix = @contact.user_specified_url.nil? ? "" : " about #{@contact.user_specified_url}"
      "Feedback#{suffix}"
    end

    def tags
      %w[anonymous_feedback public_form long_form_contact]
    end

  protected

    def template_name
      "long_form_contact"
    end

    def requester
      { email: ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL, name: "Anonymous feedback" }
    end
  end
end
