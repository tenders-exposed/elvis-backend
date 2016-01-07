Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.action_mailer.default_url_options = { host: "localhost", port: "4200" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "mail.tenders.exposed",
    port: 587,
    domain: "strix.umbra.xyz",
    authentication: :login,
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    enable_starttls_auto: true,
    openssl_verify_mode: "none"
  }

  config.action_mailer.perform_deliveries = true
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  Mongo::Logger.logger.level = ::Logger::FATAL

end
