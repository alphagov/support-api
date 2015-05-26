FactoryGirl.define do
  factory :anonymous_contact, class: AnonymousContact do
    javascript_enabled true
    path "/vat-rates"

    factory :problem_report, class: ProblemReport

    factory :service_feedback, class: ServiceFeedback do
      path { "/done/#{slug}" }
      slug "apply-carers-allowance"
      service_satisfaction_rating 5
    end

    factory :long_form_contact, class: LongFormContact
  end

  factory :organisation do
    slug "ministry-of-magic"
    web_url { "https://www.gov.uk/government/organisations/#{slug}" }
    title "Ministry of Magic"
    acronym "MOM"
    govuk_status "live"
    sequence(:content_id) { |n| "content_id_#{n}" }
  end

  factory :content_item do
    path "/search"
  end

  factory :feedback_export_request do
    path_prefix "/"
    filter_from Date.new(2015,5)
    filter_to Date.new(2015,6)
    notification_email "foo@example.com"
  end
end
