module Tabular
  # This module is used as a namespace for the services layer. The services
  # layer contains the lop level business logic for the application.
  module Services
    autoload :Passwords, 'tabular/services/passwords'
    autoload :Sessions, 'tabular/services/sessions'
    autoload :Tabs, 'tabular/services/tabs'
    autoload :Users, 'tabular/services/users'
  end
end
