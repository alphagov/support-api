class GlobalExportCsvGenerator
  def initialize(from_date, to_date, exclude_spam)
    @from_date = from_date
    @to_date = to_date
    @exclude_spam = exclude_spam
  end

  def call
    [filename, generate_csv]
  end

private

  attr_reader :from_date, :to_date

  def results
    results = ProblemReport
      .created_between_days(from_date, to_date)
      .select("date(created_at) as created_at_date, COUNT(id) as report_count")
      .group("created_at_date")
      .order("created_at_date")

    results = results.where(marked_as_spam: false) if @exclude_spam

    results.limit(10_000)
  end

  def generate_csv
    CSV.generate do |csv|
      csv << %w[date report_count]
      results.each { |r| csv << [r[:created_at_date].strftime("%Y-%m-%d"), r[:report_count]] }
    end
  end

  def filename
    "feedex_#{from_date.iso8601}_#{to_date.iso8601}#{@exclude_spam ? '_spam_excluded' : ''}.csv"
  end
end
