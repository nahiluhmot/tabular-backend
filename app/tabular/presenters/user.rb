module Tabular
  module Presenters
    # This module contains the presentation logic for users.
    class User
      def initialize(user)
        @user = user
      end

      def present(opts = {})
        options = { only: [:username] }
        options[:only] += [:followees_count, :followers_count] if opts[:counts]
        @user.as_json(options)
      end
    end
  end
end
