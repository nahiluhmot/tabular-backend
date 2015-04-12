module Tabular
  module Services
    # This service is used to perform operations on collections of users, such
    # as creating a user (which is viewed as adding one to the collection).
    module Passwords
      # Minimum length for passwords
      MINIMUM_PASSWORD_SIZE = 8.freeze

      # Number of bytes of hashed passwords.
      SCRYPT_KEY_SIZE = 512.freeze

      # Number of bytes of salt to generate.
      SCRYPT_SALT_SIZE = 32.freeze

      module_function

      # Generate a random salt.
      def generate_salt
        SCrypt::Engine.generate_salt(salt_size: SCRYPT_SALT_SIZE)
      end

      # Hash given password and salt.
      def hash_password(password, salt)
        SCrypt::Engine.hash_secret(password, salt, SCRYPT_KEY_SIZE)
      end

      # Validate that the new password matches its confirmation and conforms the
      # the minimum length restriction.
      def validate_new_password!(password, password_confirmation)
        fail Errors::PasswordsDoNotMatch if password != password_confirmation
        fail Errors::PasswordTooShort if password.length < MINIMUM_PASSWORD_SIZE
      end

      # Attempt to match a password and salt against the given hash, failing
      # if if does not match.
      def authenticate!(password, salt, hash)
        fail Errors::BadPassword unless hash_password(password, salt) == hash
      end
    end
  end
end
