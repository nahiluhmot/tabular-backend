module Tabular
  module Presenters
    # This module contains the presentation logic comment.
    class Comment
      def initialize(comment)
        @comment = comment
      end

      def present(options = nil)
        tab, user = (options || {}).values_at(:tab, :user)
        json = { only: [:id, :body], include: {} }
        json[:include][:tab] = { only: [:id, :artist, :album, :title] } if tab
        json[:include][:user] = { only: :username } if user
        @comment.as_json(json)
      end
    end
  end
end
