require 'erb'
require 'formatador'
require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'sinatra/activerecord/rake'
require 'pry'

ENV['RACK_ENV'] ||= 'development'

# Load all of the rake tasks.
Dir['tasks/**/*.rake'].each(&method(:load))

desc 'Run the app build'
task default: :build
