module AnonymousFeedback
  class ServiceFeedbackController < ApplicationController
    def create
      request = ServiceFeedback.new(service_feedback_params)

      if request.valid?
        ServiceFeedbackWorker.perform_async(service_feedback_params)
        render nothing: true, status: 202
      else
        render json: { "errors" => request.errors.to_a }, status: 422
      end
    end

    private
    def service_feedback_params
      params.require(:service_feedback).permit(
        :slug, :path, :referrer, :javascript_enabled, :user_agent, :details, :service_satisfaction_rating
      )
    end
  end
end
