require 'simplecov'
SimpleCov.start

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
