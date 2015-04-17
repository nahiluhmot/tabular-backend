# == Schema Information
#
# Table name: activity_logs
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  activity_id   :integer          not null
#  activity_type :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

module Tabular
  module Models
    # This model represents an action that was performed by the user. It is used
    # to generate the user's homepage and the recent activity feed for a user.
    class ActivityLog < ActiveRecord::Base
      self.table_name = 'activity_logs'

      VALID_ACTIVITY_TYPES = [Comment.name, Tab.name]

      belongs_to :user

      belongs_to :activity,
        polymorphic: true

      validates :user_id,
        presence: true

      validates :activity_id,
        presence: true,
        uniqueness: { scope: :activity_type }

      validates :activity_type,
        presence: true,
        inclusion: { in: VALID_ACTIVITY_TYPES }

      validates_associated :user

      validates_associated :activity
    end
  end
end
