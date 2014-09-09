require 'support/requests/anonymous/service_feedback'

class ServiceFeedbackWorker
  include Sidekiq::Worker

  def perform(service_feedback_params)
    Support::Requests::Anonymous::ServiceFeedback.new(service_feedback_params).save!
  end
end
