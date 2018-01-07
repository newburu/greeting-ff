class Follower < ApplicationRecord
  belongs_to :user

  # フォロワーの状態チェック
  def check_status
    # 一旦、新規状態にする
    self.new_flg = true
    self.change_name_flg = false
    self.change_screen_name_flg = false
    self.mutual_flg = false
    
    # 以前のフォロワー一覧に存在するか
    before_follower = BeforeFollower.find_by(user: self.user, uid: self.uid)
    if before_follower.present?
      self.new_flg = false
      # 変更箇所チェック
      self.change_name_flg = true if before_follower.name != self.name
      self.change_screen_name_flg = true if before_follower.screen_name != self.screen_name
    end

    # フレンド（フォロー）一覧に存在するか
    friend = Friend.find_by(user: self.user, uid: self.uid)
    self.mutual_flg = true if friend.present?

  end

  # 新規フォロワーさん取得
  def self.new_followers(user)
    Follower.where(user: user, new_flg: true)
  end

  # 名前変更フォロワーさん取得
  def self.change_name_followers(user)
    Follower.where(user: user, change_name_flg: true)
  end

  # ユーザ名変更フォロワーさん取得
  def self.change_screen_name_followers(user)
    Follower.where(user: user, change_screen_name_flg: true)
  end

end
