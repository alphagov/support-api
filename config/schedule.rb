# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'

set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}

# We need Rake to use our own environment
job_type :rake, "cd :path && govuk_setenv support-api bundle exec rake :task :output"

every 1.day, :at => '12:30 am' do
  rake "performance_platform_uploads:push_service_feedback"
end

every 1.day, :at => '12:10 am' do
  rake "anonymous_feedback_deduplication:nightly"
end

every 5.minutes, at: 3 do
  rake "anonymous_feedback_deduplication:recent"
end
