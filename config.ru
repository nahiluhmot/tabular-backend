# This file initializes the web application.
constants = Tabular::Controllers.constants.map(&Tabular::Controllers.method(:const_get))
controllers = constants.select { |const| const.is_a?(Class) && (const < Sinatra::Base) }
run Rack::Cascade.new(controllers)
