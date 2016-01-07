require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Elvis
  class Application < Rails::Application

    config.action_mailer.raise_delivery_errors = true
    config.time_zone = 'UTC'
    config.active_job.queue_adapter = :sidekiq


    config.exceptions_app = self.routes

    Mongoid.logger.level = Logger::DEBUG

    config.action_dispatch.default_headers = {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => 'GET, PATCH, PUT, POST, OPTIONS, DELETE',
        'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
    }

  end
end
