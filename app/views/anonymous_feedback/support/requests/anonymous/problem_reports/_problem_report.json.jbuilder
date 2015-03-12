json.type "problem-report"
json.url Plek.new.website_root + problem_report.path
json.(problem_report, :id, :created_at, :what_wrong, :what_doing, :referrer, :user_agent)
