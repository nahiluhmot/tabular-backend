module Tabular
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class Base < Sinatra::Base
      set :raise_errors, false
      set :show_exceptions, false

      before { content_type :json }

      error do |err|
        case err
        when Errors::InvalidModel, Errors::PasswordTooShort,
             Errors::MalformedRequest, Errors::PasswordsDoNotMatch
          status 400
        when Errors::BadPassword
          status 401
        when Errors::Unauthorized
          status 403
        when Errors::NoSuchModel
          status 404
        when Errors::Conflict
          status 409
        else
          status 500
        end
      end

      def session_key
        request.headers[SESSION_KEY_HEADER]
      end

      def request_body
        JSON.parse(request.body.tap(&:rewind).read).symbolize_keys
      rescue JSON::JSONError => ex
        raise Errors::MalformedRequest, ex
      end
    end
  end
end
