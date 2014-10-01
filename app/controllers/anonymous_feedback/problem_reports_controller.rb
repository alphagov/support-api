module AnonymousFeedback
  class ProblemReportsController < ApplicationController
    def totals
      date = DateTime.parse(params[:date]) rescue nil

      if date.nil?
        head 404
      else
        totals = Support::Requests::Anonymous::ProblemReport.totals_for(date)
        result = {
          date: date.to_time.iso8601,
          data: totals.map { |entry| { path: entry.path, total: entry.total } }
        }

        render json: result
      end
    end

    def create
      request = Support::Requests::Anonymous::ProblemReport.new(problem_report_params)

      if request.valid?
        ProblemReportWorker.perform_async(problem_report_params)
        render nothing: true, status: 202
      else
        render json: { "errors" => request.errors.to_a }, status: 422
      end
    end

  private
    def problem_report_params
      params.require(:problem_report).permit(
        :path, :referrer, :javascript_enabled, :user_agent, :what_doing,
        :what_wrong, :source, :page_owner
      )
    end
  end
end
