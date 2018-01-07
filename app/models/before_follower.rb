class BeforeFollower < ApplicationRecord
  belongs_to :user

  # フォロワーの状態チェック
  def check_status
    # 現在のフォロワー一覧に存在するか
    follower = Follower.find_by(user: self.user, uid: self.uid)
    self.remove_flg = true if follower.nil?
  end

  # 外れたフォロワーさん取得
  def self.remove_followers(user)
    BeforeFollower.where(user: user, remove_flg: true)
  end

end
