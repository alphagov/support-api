require "sidekiq"

if ENV["RACK_ENV"]
  namespace = "support-api-#{ENV['RACK_ENV']}"
else
  namespace = "support-api"
end

redis_details = YAML.load_file(File.join(Rails.root, "config", "redis.yml"))
redis_config = {
  url: "redis://#{redis_details['host']}:#{redis_details['port']}/0",
  namespace: namespace
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.server_middleware do |chain|
    chain.add Sidekiq::Statsd::ServerMiddleware, env: 'govuk.app.support-api', prefix: 'workers'
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
