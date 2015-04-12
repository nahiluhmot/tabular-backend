Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# This is the top level module for the application, used only as a namespace.
module Tabular
  autoload :Controllers, 'tabular/controllers'
  autoload :Models, 'tabular/models'
  autoload :Queries, 'tabular/queries'
end
