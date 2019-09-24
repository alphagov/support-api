require "date_parser"

class ProblemReportList
  def initialize(problem_report_index_params)
    @params = problem_report_index_params
  end

  def to_json
    list = {
      results: results,
      total_count: total_count,
      current_page: current_page,
      pages: pages,
      page_size: AnonymousContact::PAGE_SIZE,
    }

    list[:from_date] = dates[0] if dates[0]
    list[:to_date] = dates[1] if dates[1]
    list[:results_limited] = results_limited if results_limited

    list.to_json
  end

private

  def dates
    from_date = DateParser.parse(@params[:from_date]) || Date.new(1970)
    to_date = DateParser.parse(@params[:to_date]) || Date.today

    [from_date, to_date].tap do |dates|
      dates.sort! if @params[:from_date] && @params[:to_date]
    end
  end

  def scope
    include_reviewed = @params[:include_reviewed] || false

    if include_reviewed
      ProblemReport.all.created_between_days(dates[0], dates[1]).most_recent_first
    else
      ProblemReport.where(reviewed: false).created_between_days(dates[0], dates[1]).most_recent_first
    end
  end

  def results_limited
    total_count >= AnonymousContact::PAGE_SIZE * AnonymousContact::MAX_PAGES
  end

  def pages
    total_count == 0 ? 0 : (total_count / AnonymousContact::PAGE_SIZE.to_f).ceil
  end

  def total_count
    @total_count ||= scope.limit(AnonymousContact::MAX_PAGES * AnonymousContact::PAGE_SIZE).count
  end

  def current_page
    pages == 0 || @params[:page].to_i < 1 ? 1 : @params[:page].to_i
  end

  def results
    if current_page > pages
      []
    else
      offset = (current_page - 1) * AnonymousContact::PAGE_SIZE
      limit = AnonymousContact::PAGE_SIZE

      scope.offset(offset).limit(limit)
    end
  end
end
