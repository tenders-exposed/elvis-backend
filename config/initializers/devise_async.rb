Devise::Async.enabled = true
Devise::Async.backend = :sidekiq
Devise::Async.queue = :default
