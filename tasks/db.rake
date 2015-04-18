namespace :db do
  desc 'Load the database configuration for Auth'
  task :load_config do
    raw_file = File.read('config/database.yml')
    evaled = ERB.new(raw_file).result(binding)
    config = YAML.load(evaled)
    ActiveRecord::Base.configurations = config
    ActiveRecord::Base.establish_connection(ENV['RACK_ENV'].to_sym)
  end
end
