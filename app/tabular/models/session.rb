# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  key        :string(255)      not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

module Tabular
  module Models
    # This class stores information about a user's logged in session(s).
    class Session < ActiveRecord::Base
      self.table_name = 'sessions'

      belongs_to :user

      validates :key,
        presence: true,
        uniqueness: true

      validates :user_id,
        presence: true

      validates_associated :user
    end
  end
end
