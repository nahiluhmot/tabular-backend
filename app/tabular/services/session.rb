module Tabular
  module Services
    # This service is used to perform actions on a single session.
    class Session
      attr_reader :model

      def initialize(key)
        @model = Models::Session.find_by(key: key)
        fail Errors::NoSuchModel if @model.nil?
      end

      def read
        model
      end

      def destroy!
        model.destroy!
      end
    end
  end
end
