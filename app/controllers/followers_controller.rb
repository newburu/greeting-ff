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
  
  # 外れたフォロワーさん一覧を表示
  def remove_index
    @user = User.find_by(name: current_user.name)
    q = params[:q] || {}
    q[:user_id_eq] = @user.id
    q[:remove_flg_eq] = true
    @q = BeforeFollower.search(q)
    @followers = @q.result.page(params[:page])
  end
  
  # フォロワーさん一覧を更新
  def update_followers
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
        follower = Follower.new(user: @user, uid: f.id, name: f.name, screen_name: f.screen_name)
        # フォロワーの状態チェック
        follower.check_status
        @user.followers << follower
      end
      @user.before_followers.each do |f|
        # フォロワーの状態チェック
        f.check_status
      end

      @user.save
      
      # 結果をDM連絡
      send_dm(client, @user)
      
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
    
    redirect_to followers_path
  end

  # フレンド（フォロー）さん一覧を更新
  def update_friends
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
      # 入れ直す為に、全削除
      @user.friends.delete_all

      # フレンド（フォロー）一覧を取得
      friend_ids = client.friend_ids(user_id: @user.uid).to_a
      friends = friend_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
      friends.each do |f|
        friend = Friend.new(user: @user, uid: f.id, name: f.name, screen_name: f.screen_name)
        @user.friends << friend
      end
      @user.followers.each do |f|
        # フォロワーの状態チェック
        f.check_status
      end

      @user.save
      
      # 結果をDM連絡
      send_dm(client, @user)
      
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in
      retry
    end
    
    redirect_to followers_path
  end

private

  # DM連絡
  def send_dm(client, user)
      if user.option.try(:dm_msg_flg)
        new_followers = Follower.new_followers(user)
        change_name_followers = Follower.change_name_followers(user)
        change_screen_name_followers = Follower.change_screen_name_followers(user)
        remove_followers = BeforeFollower.remove_followers(user)

        msg = "#FFさんに挨拶 よりお知らせ\r\n\r\n"
        msg += "◆#{I18n.t('activerecord.attributes.follower.new_flg')}フォロワーさん\r\n"
        msg += "なし\r\n" if new_followers.blank?
        new_followers.each do |f|
          msg += "#{Settings.system[:twitter][:url]}#{f.screen_name}\r\n"
        end
        msg += "◆#{I18n.t('activerecord.attributes.follower.change_name_flg')}フォロワーさん\r\n"
        msg += "なし\r\n" if change_name_followers.blank?
        change_name_followers.each do |f|
          msg += "#{Settings.system[:twitter][:url]}#{f.screen_name}\r\n"
        end
        msg += "◆#{I18n.t('activerecord.attributes.follower.change_screen_name_flg')}フォロワーさん\r\n"
        msg += "なし\r\n" if change_screen_name_followers.blank?
        change_screen_name_followers.each do |f|
          msg += "#{Settings.system[:twitter][:url]}#{f.screen_name}\r\n"
        end
        msg += "◆#{I18n.t('activerecord.attributes.before_follower.remove_flg')}フォロワーさん\r\n"
        msg += "なし\r\n" if remove_followers.blank?
        remove_followers.each do |f|
          msg += "#{Settings.system[:twitter][:url]}#{f.screen_name}\r\n"
        end
        msg += "\r\n詳細はログインしてご確認ください。\r\n#{root_url}"

        client.create_direct_message(user.uid, msg)
      end
  end

end
