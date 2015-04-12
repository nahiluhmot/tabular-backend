# == Schema Information
#
# Table name: tabs
#
#  id         :integer          not null, primary key
#  body       :text(65535)      not null
#  artist     :string(255)      not null
#  album      :string(255)      not null
#  title      :string(255)      not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

module Tabular
  module Models
    # This class stores raw tab information. Its corresponding database table
    # contains a fulltext index on the artist, album, and title to allow for
    # natural language song searching.
    class Tab < ActiveRecord::Base
      self.table_name = 'tabs'

      belongs_to :user

      validates :body,
        presence: true

      validates :artist,
        presence: true

      validates :album,
        presence: true

      validates :title,
        presence: true

      validates :user_id,
        presence: true

      validates_associated :user
    end
  end
end
