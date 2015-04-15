module Tabular
  module Presenters
    # This module contains the presentation logic tabs.
    class Tab
      def initialize(tab)
        @tab = tab
      end

      def present(options = {})
        json = { only: [:id, :artist, :album, :title], include: {} }
        json[:only] << :body unless options[:short]
        if options[:comments]
          json[:include][:comments] = {
            only: [:id, :body], include: { user: { only: :username } }
          }
        end
        json[:include][:user] = { only: :username } if options[:user]
        @tab.as_json(json)
      end
    end
  end
end
