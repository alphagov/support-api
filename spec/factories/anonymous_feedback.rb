FactoryGirl.define do
  factory :anonymous_contact, class: AnonymousContact do
    javascript_enabled true
    path "/vat-rates"
    user_agent "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0;)"
    referrer "http://www.example.com/foo"

    factory :problem_report, class: ProblemReport

    factory :service_feedback, class: ServiceFeedback do
      path { "/done/#{slug}" }
      slug "apply-carers-allowance"
      service_satisfaction_rating 5
    end

    factory :aggregated_service_feedback, class: AggregatedServiceFeedback do
      path { "/done/#{slug}" }
      slug "apply-carers-allowance"
    end

    factory :long_form_contact, class: LongFormContact
  end

  factory :organisation do
    slug { title.parameterize }
    web_url { "https://www.gov.uk/government/organisations/#{slug}" }
    title "Ministry of Magic"
    acronym { title.split.map { |s| s[0] }.join.upcase }
    govuk_status "live"
    sequence(:content_id) { |n| "content_id_#{n}" }

    factory :gds do
      content_id "af07d5a5-df63-4ddc-9383-6a666845ebe9"
      slug "government-digital-service"
      web_url "https://www.gov.uk/government/organisations/government-digital-service"
      title "Government Digital Service"
    end

    factory :dfid do
      content_id "db994552-7644-404d-a770-a2fe659c661f"
      slug "department-for-international-development"
      web_url "https://www.gov.uk/government/organisations/department-for-international-development"
      title "Department for International Development"
    end

    factory :ukti do
      content_id "b045c8df-d3c4-4219-88d8-264dc9ee5cc8"
      slug "uk-trade-investment"
      web_url "https://www.gov.uk/government/organisations/uk-trade-investment"
      title "UK Trade & Investment"
    end

    factory :fco do
      content_id "9adfc4ed-9f6c-4976-a6d8-18d34356367c"
      slug "foreign-commonwealth-office"
      web_url "https://www.gov.uk/government/organisations/foreign-commonwealth-office"
      title "Foreign & Commonwealth Office"
    end

    factory :hmrc do
      content_id "6667cce2-e809-4e21-ae09-cb0bdc1ddda3"
      slug "hm-revenue-customs"
      web_url "https://www.gov.uk/government/organisations/hm-revenue-customs"
      title "HM Revenue & Customs"
    end
  end

  factory :content_item do
    path "/search"
  end

  factory :feedback_export_request do
    filters Hash.new(path_prefix: "/",
                     from: Date.new(2015,5),
                     to: Date.new(2015,6))
    notification_email "foo@example.com"
  end
end
