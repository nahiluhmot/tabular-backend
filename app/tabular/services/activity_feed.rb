module Tabular
  module Services
    # This services handles loading the activity feed for users.
    module ActivityFeed
      module_function

      FEED_QUERY = <<-EOS.freeze
        SELECT activity_logs.*
        FROM activity_logs
        WHERE activity_logs.user_id IN (
          SELECT relationships.followee_id
          FROM relationships
          WHERE relationships.follower_id IN (
            SELECT sessions.user_id
            FROM sessions
            WHERE sessions.key = :session_key
          )
        )
        ORDER BY activity_logs.created_at DESC, activity_logs.id DESC
        LIMIT :limit
        OFFSET :offset
      EOS

      def feed_for!(key, options = {})
        limit, page = validate_feed_options!(options)

        Models::ActivityLog.find_by_sql([
          FEED_QUERY, limit: limit, offset: (page - 1) * limit, session_key: key
        ]).tap do |results|
          if results.empty? && !Models::Session.exists?(key: key)
            fail Errors::Unauthorized
          end
        end
      end

      def validate_feed_options!(options)
        fail Errors::MalformedRequest unless options.is_a?(Hash)
        limit, page = options.values_at(:limit, :page).map(&:to_i)
        fail Errors::MalformedRequest unless limit.is_a?(Integer) && (limit > 0)
        fail Errors::MalformedRequest unless page.is_a?(Integer) && (page > 0)
        [limit, page]
      end
    end
  end
end
