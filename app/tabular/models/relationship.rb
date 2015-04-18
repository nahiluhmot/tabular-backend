# == Schema Information
#
# Table name: relationships
#
#  id          :integer          not null, primary key
#  followee_id :integer          not null
#  follower_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

module Tabular
  module Models
    # This class stores information about a user's logged in session(s).
    class Relationship < ActiveRecord::Base
      self.table_name = 'relationships'

      belongs_to :followee,
        class_name: User.name

      belongs_to :follower,
        class_name: User.name

      validates :followee_id,
        presence: true

      validates :follower_id,
        presence: true

      validate :ensure_unique_follower_and_followee!

      validate :ensure_follower_and_followee_different!

      validates_associated :followee

      validates_associated :follower

      private

      def ensure_unique_follower_and_followee!
        query = as_json(only: [:follower_id, :followee_id])
        return unless Relationship.exists?(query)
        errors.add(:follower_id, "already follows #{followee_id}")
        errors.add(:followee_id, "is already followed by #{follower_id}")
      end

      def ensure_follower_and_followee_different!
        return unless follower_id == followee_id
        errors.add(:follower_id, "cannot follow #{followee_id}")
        errors.add(:followee_id, "cannot be followed by #{follower_id}")
      end
    end
  end
end
