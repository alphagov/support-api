class ServiceFeedbackJob
  include Sidekiq::Job

  def perform(service_feedback_params)
    ServiceFeedback.new(service_feedback_params).save!
  end
end

ServiceFeedbackWorker = ServiceFeedbackJob ## TODO: Remove once queued jobs at the time of the upgrade are complete
