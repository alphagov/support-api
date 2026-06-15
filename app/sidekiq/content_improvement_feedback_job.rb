class ContentImprovementFeedbackJob
  include Sidekiq::Job

  def perform(feedback_params)
    ContentImprovementFeedback.create!(feedback_params)
  end
end
