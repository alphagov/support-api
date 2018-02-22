class FeedbackByDay
  attr_reader :date
  def self.retrieve(date)
    new(date).retrieve
  end

  def initialize(date)
    @date = date
  end

  def retrieve
    AnonymousContact.where(created_at: get_range)
      .group(:path).order(:path).count(:id).map do |k, v|
      {path: k, count: v}
    end
  end

private
  def get_range
    date.beginning_of_day..date.end_of_day
  end
end
