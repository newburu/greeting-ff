class AddFlagToFollower < ActiveRecord::Migration[5.1]
  def change
    add_column :followers, :new_flg, :boolean                  # 新規かフラグ
    add_column :followers, :change_name_flg, :boolean          # IDが変わったかフラグ
    add_column :followers, :change_screen_name_flg, :boolean   # 名称が変わったかフラグ
  end
end
