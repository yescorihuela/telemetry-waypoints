sidekiq_config = { url: ENV.fetch('JOB_WORKER_URL') {'0.0.0.0'} }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end