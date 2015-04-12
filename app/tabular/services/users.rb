module Tabular
  module Services
    # This service is used to perform operations on collections of users, such
    # as creating a user (which is viewed as adding one to the collection).
    module Users
      module_function

      # Create a new user.
      def create(username, password, confirmation)
        salt, hash = Passwords.validate_new_password!(password, confirmation)
        Models::User.create!(
          username: username,
          password_salt: salt,
          password_hash: hash
        )
      rescue => ex
        raise Errors::InvalidModel, ex
      end
    end
  end
end
