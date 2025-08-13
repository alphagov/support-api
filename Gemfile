source "https://rubygems.org"

gem "rails", "8.0.2.1"

gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "csv"
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
