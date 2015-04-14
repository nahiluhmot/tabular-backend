module Tabular
  module Controllers
    # This controller handles requests dealing with users.
    class Users < Base
      helpers do
        include Services::Users
        include Services::Sessions
      end

      # Create a new user and log them in.
      post '/users/?' do
        status 201
        create_user!(
          *request_body(:username, :password, :password_confirmation)
        ).as_json(only: :username).to_json
      end

      # Update a user, in this case only updating their password.
      put '/users/' do
        status 204

        password, confirmation = request_body(:password, :password_confirmation)
        user = update_password!(session_key, password, confirmation)
        session = login!(user.username, password)

        response.set_cookie :session_key,
          value: session.key,
          expires: 7.days.from_now

        session.as_json(only: :key).to_json
      end

      # Delete the user if they're logged in.
      delete '/users/' do
        status 204
        destroy_user!(session_key)
      end
    end
  end
end
