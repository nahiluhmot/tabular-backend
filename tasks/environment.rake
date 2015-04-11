namespace :environment do
  desc 'Require the application'
  task :app do
    $LOAD_PATH << File.expand_path('app', '.')
    require 'tabular'
  end

  desc 'Run all of the application initializers'
  task initializers: :"environment:app" do
    Dir['config/initializers/**/*.rb'].each(&method(:load))
  end
end

desc 'Load the application environment'
task environment: %i(db:load_config environment:app environment:initializers)
