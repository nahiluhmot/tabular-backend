module Tabular
  # This module is used as a namespace for the controllers.
  module Controllers
    SESSION_KEY_HEADER = 'X_TABULAR_SESSION_KEY'.freeze

    autoload :Base, 'tabular/controllers/base'
    autoload :Comments, 'tabular/controllers/comments'
    autoload :Relationships, 'tabular/controllers/relationships'
    autoload :Sessions, 'tabular/controllers/sessions'
    autoload :Tabs, 'tabular/controllers/tabs'
    autoload :Users, 'tabular/controllers/users'

    # A list of all of the controllers.
    Controllers = constants.map(&method(:const_get)).select do |constant|
      constant.is_a?(Class) && constant.ancestors.include?(Sinatra::Base)
    end

    # This is the main rack application used by config.ru
    Main = Rack::Cascade.new(Controllers)
  end
end
