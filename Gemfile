source 'https://rubygems.org'

gem 'rails', '4.2.2'
gem 'rails-api', '0.4.0'
gem 'pg', '0.18.2'
gem 'logstasher', '0.6.2'
gem 'airbrake', '4.1.0'
gem 'sidekiq', '3.3.4'
gem 'sidekiq-statsd', '0.1.5'
gem 'unicorn', '4.9.0'
gem 'gds-api-adapters', '20.1.1'
gem 'whenever', '0.9.4', require: false
gem 'mlanett-redis-lock', '0.2.6'
gem "gds_zendesk", '2.0.0'
gem "plek", "1.10.0"
gem 'kaminari', "~> 0.16.3"
gem 'user_agent_parser'

group :development do
  gem 'spring', '1.3.5'
end

group :development, :test do
  gem 'rspec-rails', '3.2.1'
  gem 'rspec-collection_matchers', '1.1.2'
  gem 'simplecov', '0.10.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter', '2.0.0'
  gem 'ci_reporter_rspec', '1.0.0'
  gem 'shoulda-matchers', '2.8.0'
  gem 'timecop', '0.7.3'
end

group :test do
  gem 'factory_girl_rails', '4.5.0'
  gem 'webmock', '1.21.0'
  gem 'fakefs', require: 'fakefs/safe'
end
