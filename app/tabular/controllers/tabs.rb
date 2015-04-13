module Tabular
  module Controllers
    # This controller handles requests dealing with tabs.
    class Tabs < Base
      TAB_ATTRIBUTE_WHITELIST = %i(artist album title body).freeze
      TAB_DISPLAY_KEYS = %i(id artist album title body user_id).freeze
      SEARCH_RESULTS_PER_PAGE = 25.freeze

      # Search for tabs.
      get '/tabs/?' do
        status 200
        query, page = params.values_at(:query, :page)
        page ||= 1
        tabs = search_tabs(query, limit: SEARCH_RESULTS_PER_PAGE, page: page)
        tabs.map { |tab| tab.as_json(only: TAB_DISPLAY_KEYS) }.to_json
      end

      # Create a tab.
      post '/tabs/?' do
        status 201
        tab = create_tab!(session_key, *request_body(*TAB_ATTRIBUTE_WHITELIST))
        tab.as_json(only: TAB_DISPLAY_KEYS).to_json
      end

      # Retrieve a tab by its id.
      get '/tabs/:id/' do |id|
        status 200
        find_tab_by_id!(id).as_json(only: TAB_DISPLAY_KEYS).to_json
      end

      # Edit a tab.
      put '/tabs/:id/?' do |id|
        status 204
        attributes = request_body.slice(*TAB_ATTRIBUTE_WHITELIST)
        update_tab!(session_key, id, attributes)
      end

      # Delete a tab.
      delete '/tabs/:id/?' do |id|
        status 204
        destroy_tab!(session_key, id)
      end
    end
  end
end
