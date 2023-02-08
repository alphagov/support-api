require "date_parser"

class AnonymousFeedbackController < ApplicationController
  before_action :clean_params

  def index
    unless at_least_one_param_present?
      head :bad_request
      return
    end

    json = {
      results:,
      total_count:,
      current_page:,
      pages:,
      page_size: AnonymousContact::PAGE_SIZE,
    }

    json[:from_date] = dates[0] if dates[0]
    json[:to_date] = dates[1] if dates[1]
    json[:results_limited] = results_limited if results_limited

    render json:
  end

private

  def at_least_one_param_present?
    params[:organisation_slug].present? || params[:path_prefixes].present? || params[:document_type].present?
  end

  def scope
    AnonymousContact
      .for_query_parameters(path_prefixes: params[:path_prefixes],
                            organisation_slug: params[:organisation_slug],
                            document_type: params[:document_type],
                            from: dates[0],
                            to: dates[1])
      .most_recent_first
  end

  def clean_params
    params[:path_prefixes] = [params[:path_prefix]] if params[:path_prefix].present?
  end

  def dates
    [DateParser.parse(params[:from]), DateParser.parse(params[:to])].tap do |dates|
      dates.sort! if dates[0] && dates[1]
    end
  end

  def total_count
    @total_count ||= scope.limit(AnonymousContact::MAX_PAGES * AnonymousContact::PAGE_SIZE).count
  end

  def results_limited
    total_count >= AnonymousContact::PAGE_SIZE * AnonymousContact::MAX_PAGES
  end

  def pages
    total_count.zero? ? 0 : (total_count / AnonymousContact::PAGE_SIZE.to_f).ceil
  end

  def current_page
    pages.zero? || params[:page].to_i < 1 ? 1 : params[:page].to_i
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
