class AddComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.text :comment_body, null: false
      t.integer :user_id, null: false
      t.integer :tab_id, null: false

      t.timestamps null: true
    end

    add_foreign_key :comments, :users, column: :user_id
    add_foreign_key :comments, :tabs, column: :tab_id

    add_index :comments, :tab_id
    add_index :comments, :user_id
  end

  def down
    drop_table :comments
  end
end
