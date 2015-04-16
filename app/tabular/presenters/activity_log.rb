module Tabular
  module Presenters
    # This class is used to present activity logs.
    class ActivityLog
      def initialize(activity_log)
        @activity = activity_log.activity
      end

      def present
        case @activity
        when Models::Comment
          { 'comment' => Comment.new(@activity).present(tab: true, user: true) }
        when Models::Tab
          { 'tab' => Tab.new(@activity).present(user: true, short: true) }
        end
      end
    end
  end
end
