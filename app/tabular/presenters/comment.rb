module Tabular
  module Presenters
    # This module contains the presentation logic for comments.
    class Comment
      def initialize(comment)
        @comment = comment
      end

      def present(options = nil)
        tab, user = (options || {}).values_at(:tab, :user)
        json = { only: [:id, :body], include: {} }
        if tab
          json[:include][:tab] = {
            only: [:id, :artist, :album, :title],
            include: { user: { only: :username } }
          }
        end
        json[:include][:user] = { only: :username } if user
        @comment.as_json(json)
      end
    end
  end
end
