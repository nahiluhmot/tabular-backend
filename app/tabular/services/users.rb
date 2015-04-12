module Tabular
  module Services
    # This service is used to perform operations on collections of users, such
    # as creating a user (which is viewed as adding one to the collection).
    module Users
      module_function

      # Create a new user.
      def create(username, password, password_confirmation)
        Passwords.validate_new_password!(password, password_confirmation)
        salt = Passwords.generate_salt
        Models::User.create!(
          username: username,
          password_salt: salt,
          password_hash: Passwords.hash_password(password, salt)
        )
      rescue => ex
        raise Errors::InvalidModel, ex
      end
    end
  end
end
