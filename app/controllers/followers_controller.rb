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

    # 更新
    @user.update_followers(twitter_client)
    
    # 結果をDM連絡
    @user.send_dm(twitter_client, root_url)
    
    redirect_to followers_path
  end

  # フレンド（フォロー）さん一覧を更新
  def update_friends
    @user = User.find_by(name: current_user.name)
    
    # 更新
    @user.update_friends(twitter_client)
    
    # 結果をDM連絡
    @user.send_dm(twitter_client, root_url)
    
    redirect_to followers_path
  end

  # フレンド（フォロー）さん、フォロワーさん一覧を更新
  def update_followers_friends
    @user = User.find_by(name: current_user.name)
    
    # 更新
    @user.update_followers(twitter_client)
    @user.update_friends(twitter_client)
    
    # 結果をDM連絡
    @user.send_dm(twitter_client, root_url)
    
    redirect_to followers_path
  end

end
