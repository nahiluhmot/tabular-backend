class AddSessions < ActiveRecord::Migration
  def up
    create_table :sessions do |t|
      t.string :key, null: false
      t.integer :user_id, null: false

      t.timestamps null: true
    end

    add_foreign_key :sessions, :users, column: :user_id
    add_index :sessions, :key, unique: true
    add_index :sessions, :user_id
  end

  def down
    drop_table :sessions
  end
end
