require 'csv'

class ProblemReport < AnonymousContact
  validates :what_doing, length: { maximum: 2 ** 16 }
  validates :what_wrong, length: { maximum: 2 ** 16 }

  scope :totals_for, ->(date) {
    where(created_at: date.beginning_of_day..date.end_of_day).
      only_actionable.
      select("path, count(path) as total").
      group(:path).
      order("total desc")
  }

  scope :with_known_page_owner, -> { where.not(page_owner: nil) }

  def type
    "problem-report"
  end

  def as_json(options = {})
    attributes_to_serialise = [
      :type, :path, :id, :created_at, :what_wrong, :what_doing,
      :referrer, :user_agent, :marked_as_spam, :reviewed
    ]
    super({
      only: attributes_to_serialise,
      methods: :url,
    }.merge(options))
  end

  def self.to_csv(reports)
    CSV.generate do |csv|
      csv << ProblemReportPresenter.header_row
      reports.each do |report|
        csv << ProblemReportPresenter.new(report).to_a
      end
    end
  end
end
