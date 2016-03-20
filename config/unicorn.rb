# Set the current app's path for later reference.
app_path = File.expand_path(File.dirname(__FILE__) + '/..')

# The number of worker processes ~= equal the number of CPU cores the server has.
worker_processes (ENV['RAILS_ENV'] == 'production' ? 2 : 1)

# For development,  listen on port 3000
listen(3000, backlog: 64) if ENV['RAILS_ENV'] == 'development'

# Listen to a socket on server
listen app_path + '/tmp/unicorn.sock', backlog: 64 if ENV['RAILS_ENV'] != 'development'


# After the timeout is exhausted, the unicorn worker will be killed and a new
# one brought up in its place.
timeout 300

# Set the working directory of this unicorn instance.
working_directory app_path

# Set the location of the unicorn pid file. This should match is put in the
# unicorn init script.
pid app_path + '/tmp/unicorn.pid'

# You should define your stderr and stdout here. If you don't, stderr defaults
# to /dev/null and you'll lose any error logging when in daemon mode.
stderr_path app_path + '/log/unicorn.log'
stdout_path app_path + '/log/unicorn.log'

# Load the app up before forking.
preload_app true

# Garbage collection settings.
GC.respond_to?(:copy_on_write_friendly=) &&
  GC.copy_on_write_friendly = true
