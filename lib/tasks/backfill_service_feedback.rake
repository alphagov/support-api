namespace :backfill_service_feedback do
  desc "Overwrites aggregated service feedback with data from performance platform"
  task :import_from_performance_platform, [:start_date_string, :end_date_string, :slug] => :environment do |t, args|
    require File.join(Rails.root, "lib", "backfill_historic_aggregated_service_feedback")

    raise "Start and end date required" unless args[:start_date_string] && args[:end_date_string]

    start_date = Date.parse(args[:start_date_string])
    end_date = Date.parse(args[:end_date_string])

    if args[:slug]
      slugs = [args[:slug]]
    else
      file_path = File.join(Rails.root, "config", "performance_platform_slugs.yml")
      slugs = YAML.load_file(File.open(file_path))["slugs"]
    end

    logger = Logger.new("#{Rails.root}/log/backfill_service_feedback.log")
    backfill_historic_service_feedback = BackfillHistoricAggregatedServiceFeedback.new(start_date, end_date, logger)

    slugs.each do |slug|
      backfill_historic_service_feedback.import_from_performance_platform(slug)
    end
  end
end
