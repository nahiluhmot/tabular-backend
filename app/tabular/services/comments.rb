module Tabular
  module Services
    # This service is used to perform CRUD operations on comments.
    module Comments
      module_function

      # Return the comments for the given tab id.
      def comments_for_tab!(tab_id)
        fail Errors::NoSuchModel unless Models::Tab.exists?(id: tab_id)
        Models::Comment.where(tab_id: tab_id).to_a
      end

      # Authenticate and comment on a tab.
      def create_comment!(session_key, tab_id, body)
        user = Users.user_for_session!(session_key)
        tab = Tabs.find_tab_by_id!(tab_id)
        Models::Comment.create!(user_id: user.id, tab_id: tab.id, body: body)
      rescue ActiveRecord::RecordInvalid => ex
        raise Errors::MalformedRequest, ex
      end

      # Authenticate and update a comment on a tab.
      def update_comment!(session_key, comment_id, body)
        comment = find_comment_by_session_and_id!(session_key, comment_id)
        comment.update!(body: body)
      rescue ActiveRecord::RecordInvalid => ex
        raise Errors::MalformedRequest, ex
      end

      # Authenticate and delete a comment on a tab.
      def destroy_comment!(session_key, comment_id)
        comment = find_comment_by_session_and_id!(session_key, comment_id)
        comment.destroy!
      end

      # Find a comment by its id.
      def find_comment_by_session_and_id!(session_key, comment_id)
        user = Users.user_for_session!(session_key)
        find_comment_by_id!(comment_id).tap do |comment|
          fail Errors::Unauthorized unless comment.user_id == user.id
        end
      end

      # Find a comment by its id.
      def find_comment_by_id!(comment_id)
        Models::Comment.find_by(id: comment_id).tap do |comment|
          fail Errors::NoSuchModel unless comment
        end
      end
    end
  end
end
