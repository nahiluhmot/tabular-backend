module Tabular
  module Services
    # This module includes all of the other services, making it convenient to
    # call methods from the service layer in one place.
    module Base
      include Crypto
      include Sessions
      include Tabs
      include Users
    end
  end
end
