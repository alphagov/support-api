class ServiceFeedbackWorker
  include Sidekiq::Worker

  def perform(service_feedback_params, _govuk_headers = nil)
    ServiceFeedback.new(service_feedback_params).save!
  end
end
