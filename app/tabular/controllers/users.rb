module Tabular
  module Controllers
    # This controller handles requests dealing with users.
    class Users < Base
      helpers do
        include Services::Presenters
        include Services::Sessions
        include Services::Users
      end

      # Get the signed in user.
      get '/users/?' do
        status 200

        present_json! user_for_session!(session_key)
      end

      # Create a new user and log them in.
      post '/users/?' do
        status 201
        username, password, _ = args =
          request_body(:username, :password, :password_confirmation)
        user = create_user!(*args)
        session = login!(username, password)

        response.set_cookie :session_key,
          value: session.key,
          path: '/',
          expires: 7.days.from_now

        present_json! user
      end

      # Update a user, in this case only updating their password.
      put '/users/?' do
        status 204

        password, confirmation = request_body(:password, :password_confirmation)
        user = update_password!(session_key, password, confirmation)
        session = login!(user.username, password)

        response.set_cookie :session_key,
          value: session.key,
          path: '/',
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
