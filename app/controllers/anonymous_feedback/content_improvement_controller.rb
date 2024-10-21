module AnonymousFeedback
  class ContentImprovementController < ApplicationController
    def create
      feedback = ContentImprovementFeedback.new(feedback_params)
      if feedback.valid?
        ContentImprovementFeedbackJob.perform_async(feedback_params)
        head :accepted
      else
        render json: { "errors" => feedback.errors.to_a }, status: :unprocessable_entity
      end
    end

  private

    def feedback_params
      params.permit(:description).to_hash
    end
  end
end
