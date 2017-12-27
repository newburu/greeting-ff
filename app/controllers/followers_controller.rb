class FollowersController < ApplicationController
  require 'twitter'
  
  # フォロワーさん一覧を更新
  def update
    @user = User.find_by(name: params[:name])
    
    # Twitterから取得
    client = Twitter::REST::Client.new do |config|
      auth = session["DEVISE"]
      p "============"
      p auth
      config.consumer_key = ENV["TWITTER_API_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET_KEY"]
      config.access_token = auth.credentials.token
      config.access_token_secret = auth.credentials.secret
    end
    begin
      p "================1"
      follower_ids = client.follower_ids(user_id: @user.uid).to_a
      p follower_ids
      p follower_ids.size
      
      followers = follower_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
      followers.each do |f|
        p f
        Follower.create(user: @user, uid: f.id, name: f.name)
      end
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
  end
end
