class CreateUserOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_options do |t|
      t.references :user, foreign_key: true
      t.boolean :dm_msg_flg

      t.timestamps
    end
  end
end
