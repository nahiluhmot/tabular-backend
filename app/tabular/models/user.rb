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

      has_many :sessions, dependent: :destroy
      has_many :tabs, dependent: :destroy

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
