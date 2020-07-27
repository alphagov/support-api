source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "6.0.3.2"

gem "fog-aws"
gem "gds-api-adapters"
gem "gds-sso"
gem "gds_zendesk"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "kaminari"
gem "mail-notify"
gem "mlanett-redis-lock"
gem "pg"
gem "plek"
gem "user_agent_parser"
gem "whenever", require: false

group :development do
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
end

group :development, :test do
  gem "ci_reporter"
  gem "ci_reporter_rspec"
  gem "climate_control"
  gem "rspec-collection_matchers"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "timecop"
end

group :test do
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "webmock"
end
