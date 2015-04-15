module Tabular
  module Controllers
    # This controller handles requests dealing with comments.
    class Comments < Base
      helpers do
        include Services::Comments
        include Services::Presenters
      end

      # Get the comments by a username, with the original tab they were
      # commented on.
      get '/users/:username/comments/?' do |username|
        status 200

        comments_for_user!(username).map do |comment|
          present! comment, tab: true
        end.to_json
      end

      # Get the comments by a tab.
      get '/tabs/:tab_id/comments/?' do |tab_id|
        status 200

        comments_for_tab!(tab_id).map do |comment|
          present! comment, user: true
        end.to_json
      end

      # Post a new comment on a tab.
      post '/tabs/:tab_id/comments/?' do |tab_id|
        status 201

        comment = create_comment!(session_key, tab_id, request_body[:body])
        present_json! comment
      end

      # Edit a comment.
      put '/comments/:comment_id/?' do |comment_id|
        status 204

        update_comment!(session_key, comment_id, request_body[:body])
      end

      # Delete a comment.
      delete '/comments/:comment_id/?' do |comment_id|
        status 204

        destroy_comment!(session_key, comment_id)
      end
    end
  end
end
