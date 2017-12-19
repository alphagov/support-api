source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
gem 'pg', '~> 0.18.2'
gem 'logstasher', '0.6.2'
gem 'govuk_sidekiq', '~> 2.0'
gem 'govuk_app_config', '~> 0.2.0'
gem 'unicorn', '5.1.0'

if ENV['API_DEV']
  gem "gds-api-adapters", :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 50.6'
end

gem 'whenever', '0.9.7', require: false
gem 'mlanett-redis-lock', '0.2.7'
gem "gds_zendesk", '3.0.0'
gem "plek", "1.12.0"
gem 'user_agent_parser'

group :development do
  gem 'listen', '~> 3.0.5'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'rspec-rails', '3.5.1'
  gem 'rspec-collection_matchers', '1.1.2'
  gem 'simplecov', '0.15.1', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter', '2.0.0'
  gem 'ci_reporter_rspec', '1.0.0'
  gem 'shoulda-matchers', '3.1.1'
  gem 'timecop', '0.7.3'
  gem 'govuk-lint'
end

group :test do
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'webmock', '~> 2.3.0'
  gem 'fakefs', require: 'fakefs/safe'
  gem "pry-byebug"
end
