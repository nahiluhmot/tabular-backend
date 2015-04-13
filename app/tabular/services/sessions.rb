module Tabular
  module Services
    # This service is used to login and logout.
    module Sessions
      module_function

      # If the given credentials are valid, create a session.
      def login!(user, password)
        id, salt, hash = user.id, user.password_salt, user.password_hash
        Passwords.authenticate!(password, salt, hash)
        Models::Session.create!(key: unique_session_keys.next, user_id: id)
      end

      # Destroy all the sessions with the given key.
      def logout!(key)
        Models::Session.destroy_all(key: key)
      end

      # An Enumerator which yields session keys.
      def unique_session_keys
        @unique_keys ||= Enumerator.new do |keys|
          loop do
            key = Passwords.generate_salt
            keys << key unless Models::Session.exists?(key: key)
          end
        end
      end
    end
  end
end
