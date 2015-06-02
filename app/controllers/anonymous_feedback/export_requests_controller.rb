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
        "filename" => export_request.filename,
        "ready" => !export_request.generated_at.nil?
      }
    else
      head 404
    end
  end

  private
    def export_request_params
      clean_params = params.require(:export_request).permit(:filter_from, :filter_to, :path_prefix, :notification_email)
      {
        filter_from: parse_date(clean_params[:filter_from]),
        filter_to: parse_date(clean_params[:filter_to]),
        path_prefix: clean_params[:path_prefix],
        notification_email: clean_params[:notification_email]
      }
    end
end
