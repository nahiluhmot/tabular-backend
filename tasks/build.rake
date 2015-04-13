namespace :build do
  desc 'Run the app specs'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.rspec_opts = ENV['RSPEC_OPTS'] if ENV['RSPEC_OPTS']
  end

  desc 'Run the quality metrics'
  RuboCop::RakeTask.new(:quality) do |cop|
    cop.patterns = ['app/**/*.rb', 'spec/**/*.rb', 'tasks/**/*.rake']
  end
end

desc 'Run the app build'
task build: %i(build:spec build:quality)
