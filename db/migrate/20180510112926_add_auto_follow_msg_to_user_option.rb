class AddAutoFollowMsgToUserOption < ActiveRecord::Migration[5.1]
  def change
    add_column :user_options, :auto_follow_msg_flg, :boolean
    add_column :user_options, :auto_follow_msg, :text
  end
end
