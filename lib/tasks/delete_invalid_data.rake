namespace :delete_invalid_data do
  desc "不要となったデータを削除するタスク"

  task :all_delete => :environment do 
    Follower.where(user: nil).delete_all
    BeforeFollower.where(user: nil).delete_all
    Friend.where(user: nil).delete_all
  end
end
