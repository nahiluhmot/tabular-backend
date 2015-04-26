class AddCounterCachesForRelationshipsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :followers_count, :integer, null: false, default: 0
    add_column :users, :followees_count, :integer, null: false, default: 0
  end

  def down
    remove_column :users, :followees_count
    remove_column :users, :followers_count
  end
end
