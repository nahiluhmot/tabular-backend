class AddRelationships < ActiveRecord::Migration
  def up
    create_table :relationships do |t|
      t.integer :followee_id, null: false
      t.integer :follower_id, null: false

      t.timestamps null: true
    end

    add_foreign_key :relationships, :users, column: :followee_id
    add_foreign_key :relationships, :users, column: :follower_id

    add_index :relationships, :followee_id
    add_index :relationships, :follower_id
    add_index :relationships, [:followee_id, :follower_id], unique: true
  end

  def down
    drop_table :relationships
  end
end
