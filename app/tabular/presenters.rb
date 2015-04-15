module Tabular
  # This module holds the presentation logic for the application.
  module Presenters
    autoload :Comment, 'tabular/presenters/comment'
    autoload :Tab, 'tabular/presenters/tab'
    autoload :User, 'tabular/presenters/user'
  end
end
