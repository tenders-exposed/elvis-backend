Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false

  config.eager_load = false

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

end
