class AddFlagToBeforeFollower < ActiveRecord::Migration[5.1]
  def change
    add_column :before_followers, :remove_flg, :boolean                  # 削除されたかフラグ
  end
end
