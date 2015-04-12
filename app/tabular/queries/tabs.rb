module Tabular
  module Queries
    # This module contains complex queries against the tabs table.
    module Tabs
      module_function

      # Perform a natural language search against the tabs table.
      def search(search_params)
        query = <<-EOS.gsub(/^\s+\*\s/, '')
          * SELECT * FROM tabs
          * WHERE MATCH (artist,album,title)
          * AGAINST (:search_params in NATURAL LANGUAGE MODE)
        EOS

        Models::Tab.find_by_sql([query, search_params: search_params])
      end
    end
  end
end
