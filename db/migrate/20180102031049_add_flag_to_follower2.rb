class AddFlagToFollower2 < ActiveRecord::Migration[5.1]
  def change
    add_column :followers, :mutual_flg, :boolean                  # 相互かフラグ
  end
end
