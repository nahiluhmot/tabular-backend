module Tabular
  module Controllers
    # This controller deals with follower/following relationships.
    class Relationships < Base
      helpers do
        include Services::Presenters
        include Services::Relationships
        include Services::Users
      end

      # Get the followers for a user.
      get '/users/:username/followers/?' do |username|
        status 200

        followers!(username).map(&method(:present!)).to_json
      end

      # Get the followers for a user.
      get '/users/:username/followees/?' do |username|
        status 200

        followees!(username).map(&method(:present!)).to_json
      end

      # Test if the logged in user follows the given username.
      get '/users/:username/is-following/?' do |username|
        status 200

        { following: follows?(session_key, username) }.to_json
      end

      # Follow a user.
      post '/users/:username/followers/?' do |username|
        status 201

        follow!(session_key, username)
        present_json! user_for_username!(username)
      end

      # Unfollow a user.
      delete '/users/:username/followers/?' do |username|
        status 204

        unfollow!(session_key, username)
      end
    end
  end
end
