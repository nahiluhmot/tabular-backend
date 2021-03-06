Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# This is the top level module for the application, used only as a namespace.
module Tabular
  autoload :Controllers, 'tabular/controllers'
  autoload :Errors, 'tabular/errors'
  autoload :Models, 'tabular/models'
  autoload :Presenters, 'tabular/presenters'
  autoload :Services, 'tabular/services'
end
