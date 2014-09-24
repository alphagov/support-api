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
  end
end
