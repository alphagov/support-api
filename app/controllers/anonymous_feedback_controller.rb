class AnonymousFeedbackController < ApplicationController
  def index
    unless params[:path_prefix].present?
      head :bad_request
      return
    end

    results = AnonymousContact.
      only_actionable.
      free_of_personal_info.
      matching_path_prefix(params[:path_prefix]).
      created_between_days(parse_date(params[:from]), parse_date(params[:to])).
      most_recent_first.
      page(params[:page]).
      per(AnonymousContact::PAGE_SIZE)

    render json: {
      results: results,
      total_count: results.total_count,
      current_page: results.current_page,
      pages: results.total_pages,
      page_size: AnonymousContact::PAGE_SIZE,
    }
  end

  def parse_date(date)
    return nil if date.nil?
    parsed_date = Date.parse(date)
  rescue ArgumentError
    return nil
  end

end
