module Tabular
  module Controllers
    # This controller deals with follower/following relationships.
    class Relationships < Base
      helpers do
        include Services::Users
        include Services::Relationships
      end

      # Get the followers for a user.
      get '/users/:username/followers/?' do |username|
        status 200

        followers!(username).map do |follower|
          follower.as_json(only: :username)
        end.to_json
      end

      # Get the followers for a user.
      get '/users/:username/followees/?' do |username|
        status 200

        followees!(username).map do |followee|
          followee.as_json(only: :username)
        end.to_json
      end

      # Follow a user.
      post '/users/:username/followers/?' do |username|
        status 201

        follow!(session_key, username)
        user_for_username!(username).as_json(only: :username).to_json
      end

      # Unfollow a user.
      delete '/users/:username/followers/?' do |username|
        status 204

        unfollow!(session_key, username)
      end
    end
  end
end
