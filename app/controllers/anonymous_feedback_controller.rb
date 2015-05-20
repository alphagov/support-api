class AnonymousFeedbackController < ApplicationController
  def index
    unless params[:path_prefix].present?
      head :bad_request
      return
    end

    from_date = parse_date(params[:from])
    to_date = parse_date(params[:to])

    from_date, to_date = [from_date, to_date].sort if from_date && to_date

    results = AnonymousContact.
      only_actionable.
      free_of_personal_info.
      matching_path_prefix(params[:path_prefix]).
      created_between_days(from_date || Time.at(0), to_date || Time.now).
      most_recent_first.
      page(params[:page]).
      per(AnonymousContact::PAGE_SIZE)

    json = {
      results: results,
      total_count: results.total_count,
      current_page: results.current_page,
      pages: results.total_pages,
      page_size: AnonymousContact::PAGE_SIZE,
    }

    json[:from_date] = from_date if from_date
    json[:to_date] = to_date if to_date

    render json: json
  end

  def parse_date(date)
    return nil if date.nil?
    parsed_date = Date.parse(date)
  rescue ArgumentError
    return nil
  end

end
