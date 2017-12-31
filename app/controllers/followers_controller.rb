class FollowersController < ApplicationController
  require 'twitter'
  
  # フォロワーさん一覧を表示
  def index
    @user = User.find_by(name: current_user.name)
    q = params[:q] || {}
    q[:user_id_eq] = @user.id
    @q = Follower.search(q)
    @followers = @q.result.page(params[:page])
  end
  
  # フォロワーさん一覧を更新
  def new_update
    @user = User.find_by(name: current_user.name)
    
    # Twitterから取得
    client = Twitter::REST::Client.new do |config|
      auth = session["DEVISE"]
      config.consumer_key = ENV["TWITTER_API_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET_KEY"]
      config.access_token = auth.credentials.token
      config.access_token_secret = auth.credentials.secret
    end
    begin
      # フォロワー一覧を入れ直す為に、全削除
      @user.backup_followers
      @user.followers.delete_all

      # フォロワー一覧を取得して、１００件ずつ情報を取得する
      follower_ids = client.follower_ids(user_id: @user.uid).to_a
      followers = follower_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
      followers.each do |f|
        Follower.create(user: @user, uid: f.id, name: f.name, screen_name: f.screen_name)
      end
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
    
    redirect_to followers_path
  end
end
