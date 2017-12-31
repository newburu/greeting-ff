class Follower < ApplicationRecord
  belongs_to :user

    # フォロワーの状態チェック
    def check_status
      p "=======check_status"
      # 一旦、新規状態にする
      self.new_flg = true
      self.change_name_flg = false
      self.change_screen_name_flg = false
      
      # 以前のフォロワー一覧に存在するか
      before_follower = BeforeFollower.find_by(user: self.user, uid: self.uid)
      p before_follower
      if before_follower.present?
        self.new_flg = false
        # 変更箇所チェック
        self.change_name_flg = true if before_follower.name != self.name
        self.change_screen_name_flg = true if before_follower.screen_name != self.screen_name
      end
      p self
    end

end
