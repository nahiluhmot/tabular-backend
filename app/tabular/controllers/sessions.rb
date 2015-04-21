module Tabular
  module Controllers
    # This controller handles requests dealing with sessions, like logging in
    # and out.
    class Sessions < Base
      helpers { include Services::Sessions }

      # Create a session by authenticating a user via username and password.
      post '/sessions/?' do
        status 204
        session = login!(*request_body(:username, :password))

        response.set_cookie :session_key,
          value: session.key,
          path: '/',
          expires: 7.days.from_now
      end

      # Logout of the active session.
      delete '/sessions/?' do
        status 204
        logout!(session_key)
      end
    end
  end
end
