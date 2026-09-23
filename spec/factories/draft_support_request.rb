FactoryBot.define do
  factory :draft_support_request, class: DraftSupportRequest do
    support_app_reference { "12345" }

    trait :no_reference do
      support_app_reference { nil }
    end
  end
end
