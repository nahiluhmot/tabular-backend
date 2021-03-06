module Tabular
  # This module is used as a namespace for the services layer. The services
  # layer contains the lop level business logic for the application.
  module Services
    autoload :ActivityLogs, 'tabular/services/activity_logs'
    autoload :Comments, 'tabular/services/comments'
    autoload :Crypto, 'tabular/services/crypto'
    autoload :Logger, 'tabular/services/logger'
    autoload :Presenters, 'tabular/services/presenters'
    autoload :Relationships, 'tabular/services/relationships'
    autoload :Sessions, 'tabular/services/sessions'
    autoload :Tabs, 'tabular/services/tabs'
    autoload :Users, 'tabular/services/users'
  end
end
