class AnonymousFeedback::ExportRequestsController < ApplicationController

  def create
    export_request = FeedbackExportRequest.new(export_request_params)

    if export_request.save
      GenerateFeedbackCsvWorker.perform_async(export_request.id)
      render nothing: true, status: 202
    else
      render json: { "errors" => export_request.errors.to_a }, status: 422
    end
  end

  def show
    export_request = FeedbackExportRequest.find_by_id(params[:id])

    if export_request
      render json: {
        "url" => export_request.url,
        "ready" => !export_request.generated_at.nil?
      }
    else
      head 404
    end
  end

  private
    def export_request_params
      params.require(:export_request).permit(:filter_from, :filter_to, :path_prefix, :notification_email)
    end
end
