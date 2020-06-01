module AnonymousFeedback
  class ServiceFeedbackController < ApplicationController
    def create
      request = ServiceFeedback.new(service_feedback_params)

      if request.valid?
        ServiceFeedbackWorker.perform_async(service_feedback_params)
        head :accepted
      else
        render json: { "errors" => request.errors.to_a }, status: :unprocessable_entity
      end
    end

  private

    def service_feedback_params
      params.require(:service_feedback).permit(
        :slug, :path, :referrer, :javascript_enabled, :user_agent, :details, :service_satisfaction_rating
      ).to_h
    end
  end
end
