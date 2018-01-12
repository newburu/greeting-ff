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
    Follower.update_followers(twitter_client, @user, session)
    
    # 結果をDM連絡
    send_dm(twitter_client, @user)
    
    redirect_to followers_path
  end

  # フレンド（フォロー）さん一覧を更新
  def update_friends
    @user = User.find_by(name: current_user.name)
    
    # 更新
    Friend.update_friends(twitter_client, @user)
    
    # 結果をDM連絡
    send_dm(twitter_client, @user)
    
    redirect_to followers_path
  end

  # フレンド（フォロー）さん、フォロワーさん一覧を更新
  def update_followers_friends
    @user = User.find_by(name: current_user.name)
    
    # 更新
    Follower.update_followers(twitter_client, @user, session)
    Friend.update_friends(twitter_client, @user)
    
    # 結果をDM連絡
    send_dm(twitter_client, @user)
    
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

        msg = "##{Settings.system[:title]} よりお知らせ\r\n\r\n"
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
