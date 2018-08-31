source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
gem 'pg', '~> 1.1.2'
gem 'govuk_sidekiq', '~> 3.0'
gem 'govuk_app_config', '~> 1.8.0'

if ENV['API_DEV']
  gem "gds-api-adapters", :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 52.8'
end

gem 'kaminari', '1.1.1'
gem 'whenever', '0.10.0', require: false
gem 'mlanett-redis-lock', '0.2.7'
gem "gds_zendesk", '3.0.0'
gem "plek", "2.1.1"
gem 'user_agent_parser'

group :development do
  gem 'listen', '~> 3.1.5'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'database_cleaner', '1.7.0'
  gem 'rspec-rails', '3.8.0'
  gem 'rspec-collection_matchers', '1.1.3'
  gem 'simplecov', '0.16.1', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter', '2.0.0'
  gem 'ci_reporter_rspec', '1.0.0'
  gem 'shoulda-matchers', '3.1.2'
  gem 'timecop', '0.9.1'
  gem 'govuk-lint'
end

group :test do
  gem 'factory_bot_rails', '~> 4.11.0'
  gem 'webmock', '~> 3.4.2'
  gem 'fakefs', require: 'fakefs/safe'
  gem "pry-byebug"
end
