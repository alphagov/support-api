module AnonymousFeedback
  class ContentImprovementController < ApplicationController
    def create
      feedback = ContentImprovementFeedback.new(feedback_params)
      if feedback.valid?
        ContentImprovementFeedbackWorker.perform_async(feedback_params)
        head :accepted
      else
        render json: { "errors" => feedback.errors.to_a }, status: 422
      end
    end

  private

    def feedback_params
      params.permit(:description).to_hash
    end
  end
end
