module Tabular
  module Services
    # This service is used to perform operations on collections of sessions.
    # The sessions are always related by a user.
    class Sessions
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def create!
        Models::Session.create!(key: unique_keys.next, user_id: user.id)
      end

      def read
        Models::Session.where(user_id: user.id).to_a
      end

      def destroy!
        Models::Session.destroy_all(user_id: user.id)
      end

      private

      def unique_keys
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
