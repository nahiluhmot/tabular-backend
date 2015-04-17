module Tabular
  module Presenters
    # This module contains the presentation logic for users.
    class User
      def initialize(user)
        @user = user
      end

      def present
        @user.as_json(only: :username)
      end
    end
  end
end
