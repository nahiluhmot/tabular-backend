module Tabular
  module Services
    # This module contains logic that deals with the tabs table.
    module Tabs
      SEARCH_QUERY = <<-EOS.freeze
        SELECT * FROM tabs
        WHERE MATCH (artist,album,title)
        AGAINST (:search_params in NATURAL LANGUAGE MODE)
        LIMIT :limit
        OFFSET :offset
      EOS

      module_function

      # Perform a natural language search against the tabs table.
      def search_tabs(search_params, opts = { limit: 25, page: 1 })
        limit, page = opts.values_at(:limit, :page)
        fail Errors::MalformedRequest unless limit.is_a?(Integer) && (limit > 0)
        fail Errors::MalformedRequest unless page.is_a?(Integer) && (page > 0)

        Models::Tab.find_by_sql([
          SEARCH_QUERY,
          search_params: search_params,
          limit: limit,
          offset: (page - 1) * limit
        ])
      end

      def create_tab!(session_key, artist, album, title, body)
        user = Users.user_for_session!(session_key)
        Models::Tab.create!(
          artist: artist,
          album: album,
          title: title,
          body: body,
          user_id: user.id
        )
      end

      def update_tab!(session_key, id, artist, album, title, body)
        user = Users.user_for_session!(session_key)
        tab = Models::Tab.find_by(id: id, user_id: user.id)
        fail Errors::NoSuchModel unless tab
        tab.update!(artist: artist, album: album, title: title, body: body)
      end

      def destroy_tab!(session_key, id)
        user = Users.user_for_session!(session_key)
        tab = Models::Tab.find_by(id: id, user_id: user.id)
        fail Errors::NoSuchModel unless tab
        tab.destroy!
      end
    end
  end
end
