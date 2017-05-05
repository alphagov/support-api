require 'problem_report_list'

module AnonymousFeedback
  class ProblemReportsController < ApplicationController
    include ActionController::MimeResponds

    before_action :load_selected_organisation, only: [:index]

    def totals
      date = DateTime.parse(params[:date]) rescue nil

      if date.nil?
        head :unprocessable_entity
      else
        totals = ProblemReport.totals_for(date)
        result = {
          date: date.to_time.iso8601,
          data: totals.map { |entry| { path: entry.path, total: entry.total } }
        }

        render json: result
      end
    end

    def index
      render json: ProblemReportList.new(problem_report_index_params).to_json
    end

    def create
      request = ProblemReport.new(problem_report_params)

      if request.valid?
        ProblemReportWorker.perform_async(problem_report_params)
        head :accepted
      else
        render json: { "errors" => request.errors.to_a }, status: 422
      end
    end

    def mark_reviewed_for_spam
      if mark_supplied_reports_as_reviewed_and_spam
        render json: { "success" => true }, status: 200
      else
        render json: { "success" => false }, status: 404
      end
    end

  private
    def problem_report_index_params
      params.permit(:from_date, :to_date, :include_reviewed, :page)
    end

    def problem_report_params
      params.require(:problem_report).permit(
        :path, :referrer, :javascript_enabled, :user_agent, :what_doing,
        :what_wrong, :source, :page_owner
      )
    end

    def mark_supplied_reports_as_reviewed_and_spam
      begin
        ProblemReport.find(reviewed_problem_reports_hash.keys).each do |problem_report|
          marked_as_spam = reviewed_problem_reports_hash[problem_report.id.to_s]

          review_attrs = { reviewed: true, marked_as_spam: marked_as_spam }

          if problem_report.update(review_attrs)
            true
          else
            false
          end
        end
      rescue ActiveRecord::RecordNotFound
        false
      end
    end

    def reviewed_problem_reports_hash
      params.require(:reviewed_problem_report_ids)
    end

    def filters
      params.permit(:period, :organisation_slug)
    end

    def parse_interval
      @interval = case filters[:period]
                  when /^\d{4}-\d{2}-\d{2}$/ then Time.strptime(filters[:period], '%Y-%m-%d').all_day
                  when /^\d{4}-\d{2}$/ then DateTime.strptime(filters[:period], '%Y-%m').all_month
                  else nil
                  end
      head :unprocessable_entity unless @interval
    end

    def load_selected_organisation
      if filters[:organisation_slug]
        @selected_organisation = Organisation.find_by(slug: filters[:organisation_slug])
        head :not_found unless @selected_organisation
      end
    end
  end
end
