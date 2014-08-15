require 'support/requests/anonymous/anonymous_contact'
require 'support/requests/anonymous/service_feedback'

FactoryGirl.define do
  factory :anonymous_contact, class: Support::Requests::Anonymous::AnonymousContact do
    javascript_enabled true

    factory :service_feedback, class: Support::Requests::Anonymous::ServiceFeedback do
      path { "/done/#{slug}" }
      slug "apply-carers-allowance"
      service_satisfaction_rating 5
    end
  end
end
