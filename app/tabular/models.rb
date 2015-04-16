module Tabular
  # This module is used as a namespace for the models.
  module Models
    autoload :ActivityLog, 'tabular/models/activity_log'
    autoload :Comment, 'tabular/models/comment'
    autoload :Relationship, 'tabular/models/relationship'
    autoload :Session, 'tabular/models/session'
    autoload :Tab, 'tabular/models/tab'
    autoload :User, 'tabular/models/user'
  end
end
