namespace :fix_misreported_service_feedback do
  desc "Moves service feedback from /service-name to /done/service-name (for a period the feedback was submitted with the wrong path for /done pages)"
  task :all, [:start_date_string, :end_date_string] => :environment do |_t, args|
    require File.join(Rails.root, "lib", "fix_misreported_done_page_service_feedback")

    raise "Start and end date required" unless args[:start_date_string] && args[:end_date_string]

    start_date = Date.parse(args[:start_date_string])
    end_date = Date.parse(args[:end_date_string])

    logger = Logger.new("#{Rails.root}/log/fix_misreported_service_feedback.log")
    fixer = FixMisreportedDonePageServiceFeedback.new(start_date, end_date, logger)
    fixer.fix_all!
  end

  task :one, [:start_date_string, :end_date_string, :slug] => :environment do |_t, args|
    require File.join(Rails.root, "lib", "fix_misreported_done_page_service_feedback")

    raise "Start date, end date, and slug required" unless args[:start_date_string] && args[:end_date_string] && args[:slug]

    start_date = Date.parse(args[:start_date_string])
    end_date = Date.parse(args[:end_date_string])

    logger = Logger.new("#{Rails.root}/log/fix_misreported_service_feedback.log")
    fixer = FixMisreportedDonePageServiceFeedback.new(start_date, end_date, logger)
    fixer.fix!(args[:slug])
  end
end
