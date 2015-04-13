module Tabular
  module Controllers
    # This controller handles requests dealing with collections of users.
    class Users < Base
      # Create a new user and log them in.
      post '/users/?' do
        status 201
        username, password, password_confirmation =
          request_body.values_at(*%i(username password password_confirmation))
        model = create_user!(username, password, password_confirmation)
        model.as_json(only: %i(username id)).to_json
      end
    end
  end
end
