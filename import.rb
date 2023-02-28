require "csv"

csvs = Dir.glob("tmp/data/*.csv")
csvs.each do |file_path|
  table = CSV.table(file_path)
  table.each do |row|
    path = row[:where_feedback_was_left].gsub("https://www.gov.uk", "")
    what_doing, what_wrong = row[:feedback].scan(/action: (.*?)\nproblem: (.*)/m)[0]

    ProblemReport.create!(
      path:,
      what_doing:,
      what_wrong:,
      referrer: row[:user_came_from],
      created_at: Date.parse(row[:creation_date]),
      javascript_enabled: true,
    )
  end
end
