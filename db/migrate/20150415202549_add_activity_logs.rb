class AddActivityLogs < ActiveRecord::Migration
  def up
    create_table :activity_logs do |t|
      t.integer :user_id, null: false, index: true
      t.integer :activity_id, null: false
      t.string :activity_type, null: false

      t.timestamps null: true
    end

    add_foreign_key :activity_logs, :users, column: :user_id
  end

  def down
    drop_table :activity_logs
  end
end
