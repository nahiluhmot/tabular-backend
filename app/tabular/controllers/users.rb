module Tabular
  module Controllers
    # This controller handles requests dealing with users.
    class Users < Base
      helpers do
        include Services::Presenters
        include Services::Sessions
        include Services::Users
      end

      # Create a new user and log them in.
      post '/users/?' do
        status 201
        args = request_body(:username, :password, :password_confirmation)
        present_json! create_user!(*args)
      end

      # Update a user, in this case only updating their password.
      put '/users/?' do
        status 204

        password, confirmation = request_body(:password, :password_confirmation)
        user = update_password!(session_key, password, confirmation)
        session = login!(user.username, password)

        response.set_cookie :session_key,
          value: session.key,
          expires: 7.days.from_now
      end

      # Delete the user if they're logged in.
      delete '/users/?' do
        status 204
        destroy_user!(session_key)
      end
    end
  end
end
