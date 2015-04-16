# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :text(65535)      not null
#  user_id    :integer          not null
#  tab_id     :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

module Tabular
  module Models
    # This class stores information about comments on a tab.
    class Comment < ActiveRecord::Base
      self.table_name = 'comments'

      belongs_to :user

      belongs_to :tab

      has_one :activity_log,
        as: :activity,
        dependent: :destroy

      validates :body,
        presence: true

      validates :user_id,
        presence: true

      validates :tab_id,
        presence: true

      validates_associated :user

      validates_associated :tab

      after_create { ActivityLog.create!(activity: self, user: user) }
    end
  end
end
