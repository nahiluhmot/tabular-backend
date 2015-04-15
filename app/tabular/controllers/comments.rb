module Tabular
  module Controllers
    # This controller handles requests dealing with comments.
    class Comments < Base
      helpers { include Services::Comments }

      COMMENT_ATTRIBUTE_WHITELIST = [:id, :body].freeze

      # Get the comments by a username, with the original tab they were
      # commented on.
      get '/users/:username/comments/?' do |username|
        status 200

        comments_for_user!(username).map do |comment|
          comment.as_json(
            only: COMMENT_ATTRIBUTE_WHITELIST,
            include: {
              tab: { only: Tabs::TAB_ATTRIBUTE_WHITELIST }
            }
          )
        end.to_json
      end

      # Get the comments by a tab.
      get '/tabs/:tab_id/comments/?' do |tab_id|
        status 200

        comments_for_tab!(tab_id).map do |comment|
          comment.as_json(
            only: COMMENT_ATTRIBUTE_WHITELIST,
            include: {
              user: { only: :username }
            }
          )
        end.to_json
      end

      # Post a new comment on a tab.
      post '/tabs/:tab_id/comments/?' do |tab_id|
        status 201

        create_comment!(session_key, tab_id, request_body[:body])
          .as_json(only: COMMENT_ATTRIBUTE_WHITELIST)
          .to_json
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
