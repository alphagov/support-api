FactoryBot.define do
  factory :content_improvement_feedback, class: ContentImprovementFeedback do
    description { 'something missing' }
    personal_information_status { 'absent' }
  end
end
