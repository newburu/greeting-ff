namespace :auto_update_data do
  desc "自動でデータを更新するタスク"

  task :all_update => :environment do
    User.auto_update_users.each do |user|
      # 更新
      user.update_followers(user.twitter_client(user))
      user.update_friends(user.twitter_client(user))

      # 結果をDM連絡
      user.send_dm(user.twitter_client(user))
      # 新規フォロワーさんに自動挨拶
      user.send_new_follower_msg(user.twitter_client(user))
    end
  end
end
