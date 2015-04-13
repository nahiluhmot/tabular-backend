module Tabular
  # This module is used as a namespace for the controllers.
  module Controllers
    SESSION_KEY_HEADER = 'X_TABULAR_SESSION_KEY'.freeze

    autoload :Base, 'tabular/controllers/base'
    autoload :Sessions, 'tabular/controllers/sessions'
    autoload :Tabs, 'tabular/controllers/tabs'
    autoload :Users, 'tabular/controllers/users'
  end
end
