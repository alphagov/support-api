class AnonymousFeedbackController < ApplicationController
  def index
    unless params[:path_prefix].present?
      head :bad_request
      return
    end

    query = Support::Requests::Anonymous::AnonymousContact.
      free_of_personal_info.
      matching_path_prefix(params[:path_prefix]).
      most_recent_first
    results = Kaminari.paginate_array(query).
      page(params[:page]).
      per(Support::Requests::Anonymous::AnonymousContact::PAGE_SIZE)

    render json: {
      results: results,
      total_count: results.total_count,
      current_page: results.current_page,
      pages: results.total_pages,
      page_size: Support::Requests::Anonymous::AnonymousContact::PAGE_SIZE,
    }
  end
end
