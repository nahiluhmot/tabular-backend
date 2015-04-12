module Tabular
  module Services
    # This service is used to perform actions on a single user.
    class User
      attr_reader :model

      # Create a new service.
      def initialize(username)
        @model = Models::User.find_by(username: username)
        fail Errors::NoSuchModel if @model.nil?
      end

      # Return the database model for the username.
      def read
        model
      end

      # Update the user's password.
      def update_password!(password, confirmation)
        salt, hash = Passwords.validate_new_password!(password, confirmation)
        model.update!(password_salt: salt, password_hash: hash)
      rescue => ex
        raise Errors::InvalidModel, ex
      end

      # Destroy the user.
      def destroy!
        model.destroy!
      end
    end
  end
end
