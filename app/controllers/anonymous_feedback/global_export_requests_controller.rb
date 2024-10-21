require "date_parser"

class AnonymousFeedback::GlobalExportRequestsController < ApplicationController
  def create
    export_request = GlobalExportRequest.new(global_export_request_params)
    if export_request.valid?
      GenerateGlobalExportCsvJob.perform_async(global_export_request_params)
      head :accepted
    else
      render json: { "errors" => export_request.errors.to_a }, status: :unprocessable_entity
    end
  end

private

  def global_export_request_params
    permitted_params = %i[
      from_date
      to_date
      notification_email
      exclude_spam
    ]

    clean_params = params.require(:global_export_request).permit(*permitted_params).to_h
    {
      from_date: DateParser.parse(clean_params[:from_date]),
      to_date: DateParser.parse(clean_params[:to_date]),
      notification_email: clean_params[:notification_email],
      exclude_spam: clean_params[:exclude_spam],
    }
  end
end
