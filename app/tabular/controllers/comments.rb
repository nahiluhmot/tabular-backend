module Tabular
  module Controllers
    # This controller handles requests dealing with comments.
    class Comments < Base
      helpers do
        include Services::Comments
        include Services::Presenters
      end

      # Get the comments by a tab.
      get '/comments/?' do
        status 200

        comments_for_tab!(params[:tab_id].to_i).map do |comment|
          present! comment, user: true
        end.to_json
      end

      # Post a new comment on a tab.
      post '/comments/?' do
        status 201
        comment = create_comment!(session_key, *request_body(:tab_id, :body))
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
