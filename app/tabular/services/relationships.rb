module Tabular
  module Services
    # This service contains functions dealing with following users.
    module Relationships
      module_function

      # Return the followers for a username.
      def followers!(username)
        Users.user_for_username!(username).followers
      end

      # Return the followers for a username.
      def followees!(username)
        Users.user_for_username!(username).followees
      end

      # Follow a user by their username.
      def follow!(session_key, username)
        follower = Users.user_for_session!(session_key)
        followee = Users.user_for_username!(username)
        Models::Relationship.create!(
          follower_id: follower.id,
          followee_id: followee.id
        )
      rescue ActiveRecord::RecordInvalid => ex
        raise Errors::Conflict, ex
      end

      # Follow a user by their username.
      def unfollow!(session_key, username)
        follower = Users.user_for_session!(session_key)
        followee = Users.user_for_username!(username)
        options = { follower_id: follower.id, followee_id: followee.id }
        fail Errors::NoSuchModel unless Models::Relationship.exists?(options)
        Models::Relationship.destroy_all(options)
      end
    end
  end
end
