class BeforeFollower < ApplicationRecord
  belongs_to :user

  # フォロワーの状態チェック
  def check_status
    # 現在のフォロワー一覧に存在するか
    follower = Follower.find_by(user: self.user, uid: self.uid)
    self.remove_flg = true if follower.nil?
  end

end
