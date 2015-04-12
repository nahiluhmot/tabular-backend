class ChangeUserPasswordHashToText < ActiveRecord::Migration
  def up
    change_column :users, :password_hash, :text, null: false
  end

  def down
    change_column :users, :password_hash, :string, null: false
  end
end
