require 'support/requests/anonymous/service_feedback'

module AnonymousFeedback
  class ServiceFeedbackController < ApplicationController
    def create
      request = Support::Requests::Anonymous::ServiceFeedback.new(service_feedback_params)

      if request.valid?
        request.save!
        render nothing: true, status: 201
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
