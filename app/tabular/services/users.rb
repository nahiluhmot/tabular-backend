module Tabular
  module Services
    # This service, whose methods mostly require a session token, contains the
    # functionality to create, update, and destroy users.
    module Users
      module_function

      # Create a new user.
      def create_user!(username, password, confirmation)
        fail Errors::Conflict if Models::User.exists?(username: username)

        salt, hash = Crypto.validate_new_password!(password, confirmation)
        Models::User.create!(
          username: username,
          password_salt: salt,
          password_hash: hash
        )
      rescue ActiveRecord::RecordInvalid => ex
        raise Errors::InvalidModel, ex
      end

      # Update the user's password.
      def update_password!(session_key, password, confirmation)
        user = user_for_session!(session_key)
        salt, hash = Crypto.validate_new_password!(password, confirmation)
        user.update!(password_salt: salt, password_hash: hash)
        Models::Session.destroy_all(user_id: user.id)
        user.tap(&:reload)
      end

      # Destroy the user.
      def destroy_user!(session_key)
        user_for_session!(session_key).destroy!
      end

      # Find a user by their username.
      def user_for_username!(username)
        fail Errors::MalformedRequest unless username
        Models::User.find_by(username: username) || fail(Errors::NoSuchModel)
      end

      # Return teh user for the given session.
      def user_for_session!(session_key)
        fail Errors::Unauthorized unless session_key
        Models::User
          .joins(:sessions)
          .readonly(false)
          .find_by(sessions: { key: session_key })
          .tap { |user| fail Errors::Unauthorized unless user }
      end
    end
  end
end
