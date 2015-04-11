# This file is used to configure unicorn.
APP_DIR = File.expand_path(File.dirname(__FILE__))
APP_PORT = (ENV['APP_PORT'] || 4567).to_i
PID_PATH = File.join(Dir.tmpdir, 'unicorn.pid')

before_fork do |_, _|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |_, _|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection(ENV['RACK_ENV'].to_sym)
  end
end

timeout 30
working_directory APP_DIR
pid PID_PATH
listen APP_PORT, backlog: 64
