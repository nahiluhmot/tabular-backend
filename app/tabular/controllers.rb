module Tabular
  # This module is used as a namespace for the controllers.
  module Controllers
    SESSION_KEY_HEADER = 'X-TABULAR-SESSION-KEY'.freeze

    autoload :Base, 'tabular/controllers/base'
    autoload :Users, 'tabular/controllers/users'
  end
end
