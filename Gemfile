source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "7.2.2"

gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "kaminari"
gem "mail-notify"
gem "mlanett-redis-lock"
gem "pg"
gem "plek"
gem "sentry-sidekiq"
gem "user_agent_parser"
gem "whenever", require: false
gem "zendesk_api"

group :development do
  gem "listen"
  gem "pact", require: false
  gem "pact_broker-client"
  gem "spring"
end

group :development, :test do
  gem "ci_reporter"
  gem "ci_reporter_rspec"
  gem "climate_control"
  gem "rspec-collection_matchers"
  gem "rspec-rails"
  gem "rubocop-govuk", ">= 4.12.0"
  gem "shoulda-matchers"
  gem "timecop"
end

group :test do
  gem "brakeman"
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "simplecov"
  gem "webmock"
end
