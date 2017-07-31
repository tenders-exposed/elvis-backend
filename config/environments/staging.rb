Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.action_mailer.default_url_options = { host: "staging.tenders.exposed" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "mail.tenders.exposed",
    port: 587,
    domain: "c14.cyanic.tech",
    authentication: :login,
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    openssl_verify_mode: "none",
    enable_starttls_auto: true
  }

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.log_level = :debug
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
end
