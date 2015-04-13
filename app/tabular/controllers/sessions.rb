module Tabular
  module Controllers
    # This controller handles requests dealing with sessions, like logging in
    # and out.
    class Sessions < Base
      # Create a session by authenticating a user via username and password.
      post '/sessions/?' do
        status 201
        session = login!(*request_body(:username, :password))

        response.set_cookie :session_key,
          value: session.key,
          expires: 7.days.from_now

        session.as_json(only: :key).to_json
      end

      # Logout of the active session.
      delete '/sessions/?' do
        status 204
        logout!(session_key)
      end
    end
  end
end
