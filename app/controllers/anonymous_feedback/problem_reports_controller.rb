module AnonymousFeedback
  class ProblemReportsController < ApplicationController
    include ActionController::MimeResponds

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

    def index
      if interval.nil?
        head 422
      elsif selected_organisation.nil?
        head 404
      else
        @results = selected_organisation.problem_reports.where(created_at: interval)
        if @results.empty?
          head 204
        else
          respond_to do |format|
            format.json { render }
            format.csv { send_data Support::Requests::Anonymous::ProblemReport.to_csv(@results) }
          end
        end
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

    def filters
      params.permit(:period, :organisation_slug)
    end

    def interval
      case filters[:period]
      when /^\d{4}-\d{2}-\d{2}$/ then Time.strptime(filters[:period], '%Y-%m-%d').all_day
      when /^\d{4}-\d{2}$/ then DateTime.strptime(filters[:period], '%Y-%m').all_month
      else nil
      end
    end

    def selected_organisation
      Organisation.where(slug: filters[:organisation_slug]).first
    end
  end
end
