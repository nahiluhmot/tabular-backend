module Tabular
  module Controllers
    # This controller handles requests dealing with collections of users.
    class Sessions < Base
      helpers { include Services::Sessions }

      # Create a session by authenticating a user via username and password.
      post '/sessions/?' do
        status 201
        session = login!(*request_body.values_at(*%i(username password)))

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
