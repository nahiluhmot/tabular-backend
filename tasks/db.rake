namespace :db do
  desc 'Load the database configuration for Auth'
  task :load_config do
    ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
    ActiveRecord::Base.establish_connection(ENV['RACK_ENV'].to_sym)
  end
end
