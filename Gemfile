source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "fog-aws", "~> 3.6"
gem "gds-api-adapters", "~> 67.0.0"
gem "gds-sso", "~> 15.0.0"
gem "gds_zendesk", "3.0.0"
gem "govuk_app_config", "~> 2.2.1"
gem "govuk_sidekiq", "~> 3.0"
gem "kaminari", "1.2.1"
gem "mail-notify"
gem "mlanett-redis-lock", "0.2.7"
gem "pg", "~> 1.2.3"
gem "plek", "4.0.0"
gem "rails", "~> 6.0.3"
gem "user_agent_parser"
gem "whenever", "1.0.0", require: false

group :development do
  gem "listen", "~> 3.2.1"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :development, :test do
  gem "ci_reporter", "2.0.0"
  gem "ci_reporter_rspec", "1.0.0"
  gem "climate_control", "~> 0.2.0"
  gem "rspec-collection_matchers", "1.2.0"
  gem "rspec-rails", "4.0.1"
  gem "rubocop-govuk", "~> 3.16"
  gem "shoulda-matchers", "4.3.0"
  gem "simplecov", "0.18.5", require: false
  gem "simplecov-rcov", "0.2.3", require: false
  gem "timecop", "0.9.1"
end

group :test do
  gem "factory_bot_rails", "~> 6.1.0"
  gem "pry-byebug"
  gem "webmock", "~> 3.8.3"
end
