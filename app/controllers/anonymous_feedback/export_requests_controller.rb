require "date_parser"

class AnonymousFeedback::ExportRequestsController < ApplicationController
  def create
    export_request = FeedbackExportRequest.new(export_request_params)

    if export_request.save
      GenerateFeedbackCsvWorker.perform_async(export_request.id)
      head :accepted
    else
      render json: { "errors" => export_request.errors.to_a }, status: 422
    end
  end

  def show
    export_request = FeedbackExportRequest.find_by_id(params[:id])

    if export_request
      render json: {
        "filename" => export_request.filename,
        "ready" => !export_request.generated_at.nil?,
      }
    else
      head :not_found
    end
  end

private

    def export_request_params
      permitted_params = [:from, :to, :organisation, :notification_email, :document_type, :path_prefix, path_prefixes: []]
      clean_params = params.require(:export_request).permit(*permitted_params).to_h
      if clean_params[:path_prefix].present?
        clean_params[:path_prefixes] = [clean_params[:path_prefix]]
        clean_params.delete(:path_prefix)
      end

      {
        filters: {
          from: DateParser.parse(clean_params[:from]),
          to: DateParser.parse(clean_params[:to]),
          path_prefixes: clean_params[:path_prefixes],
          organisation_slug: clean_params[:organisation],
          document_type: clean_params[:document_type],
        },
        notification_email: clean_params[:notification_email],
      }
    end
end
