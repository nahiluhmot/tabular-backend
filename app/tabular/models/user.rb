# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  username      :string(255)      not null
#  password_hash :text(65535)      not null
#  password_salt :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

module Tabular
  module Models
    # This class represents a user in the database.
    class User < ActiveRecord::Base
      self.table_name = 'users'

      has_many :sessions,
        dependent: :destroy

      has_many :tabs,
        dependent: :destroy

      has_many :comments,
        dependent: :destroy

      has_many :activity_logs,
        dependent: :destroy

      has_many :followee_relationships,
        class_name: Relationship.name,
        foreign_key: :followee_id,
        dependent: :destroy

      has_many :follower_relationships,
        class_name: Relationship.name,
        foreign_key: :follower_id,
        dependent: :destroy

      has_many :followees,
        through: :follower_relationships

      has_many :followers,
        through: :followee_relationships

      validates :username,
        presence: true,
        uniqueness: true,
        length: { minimum: 1 },
        format: { with: /\A\w+\z/ }

      validates :password_hash,
        presence: true

      validates :password_salt,
        presence: true
    end
  end
end
