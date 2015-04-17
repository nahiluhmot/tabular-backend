module Tabular
  module Services
    # This services handles loading the activity feed for users.
    module ActivityFeed
      module_function

      FEED_QUERY = <<-EOS.freeze
        SELECT activity_logs.*
        FROM activity_logs
        INNER JOIN relationships
        ON activity_logs.user_id = relationships.followee_id
        WHERE relationships.follower_id IN (
          SELECT sessions.user_id
          FROM sessions
          WHERE sessions.key = :session_key
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

      def recent_activity_for!(username, options = {})
        limit, page = validate_feed_options!(options)
        Models::ActivityLog
          .joins(:user)
          .where(users: { username: username })
          .order(created_at: :desc, id: :desc)
          .limit(limit)
          .offset(page.pred * limit)
          .tap { |logs| validate_recent_activity_results!(username, logs) }
      end

      def validate_feed_options!(options)
        fail Errors::MalformedRequest unless options.is_a?(Hash)
        limit, page = options.values_at(:limit, :page).map(&:to_i)
        fail Errors::MalformedRequest unless limit.is_a?(Integer) && (limit > 0)
        fail Errors::MalformedRequest unless page.is_a?(Integer) && (page > 0)
        [limit, page]
      end

      def validate_recent_activity_results!(username, logs)
        if logs.empty? && !Models::User.exists?(username: username)
          fail Errors::NoSuchModel
        end
        logs
      end
    end
  end
end
