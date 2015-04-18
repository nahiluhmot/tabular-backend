namespace :environment do
  desc 'Require the application'
  task :app do
    $LOAD_PATH << File.expand_path('app', '.')
    require 'tabular'
  end

  desc 'Run all of the application initializers'
  task initializers: [:'db:load_config', :'environment:app'] do
    Dir['config/initializers/**/*.rb'].each(&method(:load))
  end
end

desc 'Load the application environment'
task environment: :'environment:initializers'
