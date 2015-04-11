class AddUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_hash, null: false
      t.string :password_salt, null: false

      t.timestamps null: true
    end

    add_index :users, :username, unique: true
  end

  def down
    drop_table :users
  end
end
