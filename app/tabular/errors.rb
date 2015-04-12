module Tabular
  # This module acts as a namespace for errors thrown throughout the app.
  module Errors
    # Top level error for application specific problems. Never thrown, but can
    # be used as a catch-all.
    BaseError = Class.new(StandardError)
  end
end
