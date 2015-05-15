class ServiceFeedbackWorker
  include Sidekiq::Worker

  def perform(service_feedback_params)
    ServiceFeedback.new(service_feedback_params).save!
  end
end
