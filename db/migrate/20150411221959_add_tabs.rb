class AddTabs < ActiveRecord::Migration
  def up
    create_table :tabs do |t|
      t.text :body, null: false
      t.string :artist, null: false
      t.string :album, null: false
      t.string :title, null: false
      t.integer :user_id, null: false

      t.timestamps null: true
    end

    add_foreign_key :tabs, :users, column: :user_id
    add_index :tabs, :user_id

    add_index :tabs, [:artist, :album, :title], type: :fulltext
  end

  def down
    drop_table :tabs
  end
end
