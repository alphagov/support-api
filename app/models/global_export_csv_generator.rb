class GlobalExportCsvGenerator
  def initialize(from_date, to_date)
    @from_date = from_date
    @to_date = to_date
  end

  def call
    return filename, generate_csv
  end

private
  attr_reader :from_date, :to_date

  def results
    ProblemReport.
      created_between_days(from_date, to_date).
      select("date(created_at) as created_at_date, COUNT(id) as report_count").
      group("created_at_date").
      order("created_at_date").
      limit(10_000)
  end

  def generate_csv
    CSV.generate do |csv|
      csv << ['date', 'report_count']
      results.each { |r| csv << [r[:created_at_date].strftime('%Y-%m-%d'), r[:report_count]] }
    end
  end

  def filename
    "feedex_#{from_date.iso8601}_#{to_date.iso8601}.csv"
  end
end
