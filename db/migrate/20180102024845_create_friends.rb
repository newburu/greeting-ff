class CreateFriends < ActiveRecord::Migration[5.1]
  def change
    create_table :friends do |t|
      t.references :user, foreign_key: true
      t.integer :uid, :limit => 8 #bigintにする
      t.string :name
      t.string :screen_name

      t.timestamps
    end
  end
end
