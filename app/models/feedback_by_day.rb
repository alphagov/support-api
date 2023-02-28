class FeedbackByDay
  attr_reader :date, :current_page, :per_page

  def self.retrieve(date, page, per_page)
    new(date, page, per_page).retrieve
  end

  def initialize(date, page, per_page)
    @date = date
    @current_page = page || 1
    @per_page = per_page || 100
  end

  def retrieve
    results = summary_query.count(:id).map do |k, v|
      { path: k, count: v }
    end
    {
      results:,
      total_count: summary_query.total_count,
      current_page: summary_query.current_page,
      pages: summary_query.total_pages,
      page_size: summary_query.limit_value,
    }
  end

private

  def summary_query
    AnonymousContact.where(created_at: get_range)
      .group(:path).page(current_page).per(per_page)
      .order(:path)
  end

  def get_range
    date.beginning_of_day..date.end_of_day
  end
end
