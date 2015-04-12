module Tabular
  module Queries
    # This module contains complex queries against the tabs table.
    module Tabs
      module_function

      SEARCH_QUERY = <<-EOS.freeze
        SELECT * FROM tabs
        WHERE MATCH (artist,album,title)
        AGAINST (:search_params in NATURAL LANGUAGE MODE)
      EOS

      # Perform a natural language search against the tabs table.
      def search(search_params)
        Models::Tab.find_by_sql([SEARCH_QUERY, search_params: search_params])
      end
    end
  end
end
