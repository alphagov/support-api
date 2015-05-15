require 'support/requests/anonymous/anonymous_contact'
require 'support/requests/anonymous/problem_report'
require 'support/requests/anonymous/service_feedback'

FactoryGirl.define do
  factory :anonymous_contact, class: Support::Requests::Anonymous::AnonymousContact do
    javascript_enabled true
    path "/vat-rates"

    factory :problem_report, class: Support::Requests::Anonymous::ProblemReport

    factory :service_feedback, class: Support::Requests::Anonymous::ServiceFeedback do
      path { "/done/#{slug}" }
      slug "apply-carers-allowance"
      service_satisfaction_rating 5
    end

    factory :long_form_contact, class: Support::Requests::Anonymous::LongFormContact
  end

  factory :organisation do
    slug "ministry-of-magic"
    web_url { "https://www.gov.uk/government/organisations/#{slug}" }
    title "Ministry of Magic"
  end

  factory :content_item do
    path "/search"
  end
end
