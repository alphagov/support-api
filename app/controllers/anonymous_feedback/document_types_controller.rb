module AnonymousFeedback
  class DocumentTypesController < ApplicationController
    def index
      render json: ContentItem.all_document_types
    end

    def show
      ordering = if %w[path last_7_days last_30_days last_90_days].include? params[:ordering]
                   params[:ordering]
                 else
                   "last_7_days"
                 end

      unless ContentItem.for_document_type(params[:document_type]).any?
        head :not_found
        return
      end

      anonymous_feedback_counts = ContentItem
          .where(document_type: params[:document_type])
          .summary(ordering)

      render json: {
          document_type: params[:document_type],
          anonymous_feedback_counts: anonymous_feedback_counts,
      }
    end
  end
end
