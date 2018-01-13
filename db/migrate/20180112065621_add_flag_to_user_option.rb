class AddFlagToUserOption < ActiveRecord::Migration[5.1]
  def change
    add_column :user_options, :auto_update_flg, :boolean   # 自動更新フラグ
  end
end
