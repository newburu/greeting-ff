class Follower < ApplicationRecord
  belongs_to :user

  # フォロワーさん一覧を更新
  def self.update_followers(client, user)
    # Twitterから取得
    begin
      # フォロワー一覧を入れ直す為に、全削除
      user.backup_followers
      user.followers.delete_all

      # フォロワー一覧を取得して、１００件ずつ情報を取得する
      follower_ids = client.follower_ids(user_id: user.uid).to_a
      followers = follower_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
      followers.each do |f|
        follower = Follower.new(user: user, uid: f.id, name: f.name, screen_name: f.screen_name)
        # フォロワーの状態チェック
        follower.check_status
        user.followers << follower
      end
      user.before_followers.each do |f|
        # フォロワーの状態チェック
        f.check_status
      end

      user.save
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
  end

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
