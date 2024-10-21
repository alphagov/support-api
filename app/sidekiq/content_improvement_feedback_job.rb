class ContentImprovementFeedbackJob
  include Sidekiq::Job

  def perform(feedback_params)
    ContentImprovementFeedback.create!(feedback_params)
  end
end

ContentImprovementFeedbackWorker = ContentImprovementFeedbackJob ## TODO: Remove once queued jobs at the time of the upgrade are complete
