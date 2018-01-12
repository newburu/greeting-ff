class Friend < ApplicationRecord
  belongs_to :user

  # フレンド（フォロー）さん一覧を更新
  def self.update_friends(client, user)
    # Twitterから取得
    begin
      # 入れ直す為に、全削除
      user.friends.delete_all

      # フレンド（フォロー）一覧を取得
      friend_ids = client.friend_ids(user_id: user.uid).to_a
      friends = friend_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
      friends.each do |f|
        friend = Friend.new(user: user, uid: f.id, name: f.name, screen_name: f.screen_name)
        user.friends << friend
      end
      user.followers.each do |f|
        # フォロワーの状態チェック
        f.check_status
      end

      user.save
      
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
  end

end
