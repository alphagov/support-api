class ContentImprovementFeedbackWorker
  include Sidekiq::Worker

  def perform(feedback_params)
    ContentImprovementFeedback.create!(feedback_params)
  end
end
