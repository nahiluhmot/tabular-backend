require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'

  add_group 'App', '/app/'
  add_group 'Controllers', '/app/tabular/controllers'
  add_group 'Models', '/app/tabular/models'
  add_group 'Presenters', '/app/tabular/presenters'
  add_group 'Services', '/app/tabular/services'
end

ENV['RACK_ENV'] ||= 'test'

$LOAD_PATH << File.expand_path('app', '.')
require 'tabular'

Dir['config/initializers/**/*.rb'].each(&method(:load))
Dir['spec/factories/**/*.rb'].each(&method(:load))

RSpec.configure do |config|
  config.include(FactoryGirl::Syntax::Methods)
  config.include(Rack::Test::Methods)

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
