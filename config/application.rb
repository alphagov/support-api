require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SupportApi
  def self.postgresql?
    ENV["SUPPORT_API_DB_TYPE"] == "postgresql"
  end

  def self.mysql?
    ENV["SUPPORT_API_DB_TYPE"].blank? || ENV["SUPPORT_API_DB_TYPE"] == "mysql"
  end

  class Application < Rails::Application
    require "support_api"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.api_only = false

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil

    if SupportApi.postgresql?
      config.active_record.schema_format = :sql
    else
      config.active_record.schema_format = :ruby
    end
  end
end
