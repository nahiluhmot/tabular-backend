module Tabular
  module Services
    # This module contains logic that deals with the tabs table.
    module Tabs
      SEARCH_QUERY = <<-EOS.freeze
        SELECT * FROM tabs
        WHERE MATCH (artist,album,title)
        AGAINST (:search_params in NATURAL LANGUAGE MODE)
      EOS

      module_function

      # Perform a natural language search against the tabs table.
      def search_tabs(search_params)
        Models::Tab.find_by_sql([SEARCH_QUERY, search_params: search_params])
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
