require 'uri'
require 'zendesk/ticket'
require 'plek'

module Zendesk
  class ProblemReportTicket < Ticket
    def subject
      @contact.path
    end

    def tags
      ["anonymous_feedback", "public_form", "report_a_problem"] +
        source_tag_if_needed + govuk_referrer_tag_if_needed + page_owner_tag_if_needed
    end

  protected
    def template_name
      'problem_report'
    end

    def requester
      { email: ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL, name: "Anonymous feedback" }
    end

    def source_tag_if_needed
      @contact.source.nil? ? [] : [ @contact.source ]
    end

    def page_owner_tag_if_needed
      @contact.page_owner.nil? ? [] : ["page_owner/#{@contact.page_owner}"]
    end

    def govuk_referrer_tag_if_needed
      referrer_url_on_gov_uk? ? ["govuk_referrer"] : []
    end

    def referrer_url_on_gov_uk?
      @contact.referrer and URI.parse(@contact.referrer).host == govuk_host
    end

    def govuk_host
      Plek.current.website_uri.host # www.gov.uk or www.preview.alphagov.co.uk
    end
  end
end
