module Tabular
  module Controllers
    # This controller serves the feed for users.
    class ActivityLogs < Base
      FEED_RESULTS_PER_PAGE = 25

      helpers do
        include Services::ActivityLogs
        include Services::Presenters
      end

      get '/feed/?' do
        status 200
        page = params[:page].try(:to_i) || 1
        feed = feed_for!(session_key, limit: FEED_RESULTS_PER_PAGE, page: page)
        feed.map(&method(:present!)).to_json
      end
    end
  end
end
