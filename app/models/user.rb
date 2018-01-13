class User < ApplicationRecord
  devise :trackable, :omniauthable
  
  # 現在のフレンド（フォロー）さん一覧
  has_many :friends
  accepts_nested_attributes_for :friends

  # 現在のフォロワーさん一覧
  has_many :followers
  accepts_nested_attributes_for :followers

  # 昔のフォロワーさん一覧
  has_many :before_followers
  accepts_nested_attributes_for :before_followers

  # 設定
  has_one :option, :class_name => "UserOption"
  accepts_nested_attributes_for :option

  validates :name, presence: true, uniqueness: true

  #############
  # スコープ
  scope :auto_update_users, -> {includes(:option).where(user_options: {auto_update_flg: true})}

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end
  
  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(name: auth.info.name,
                         screen_name: auth.info.nickname,
                          provider: auth.provider,
                          uid: auth.uid,
#                          email:auth.extra.user_hash.email, #色々頑張りましたがtwitterではemail取得できません
                          password: Devise.friendly_token[0,20],
                          access_token: auth.credentials.token,
                          access_token_secret: auth.credentials.secret
                          )
    else
      user.update(access_token: auth.credentials.token,access_token_secret: auth.credentials.secret)
    end
    user
  end

  # FollowersをBeforeFollowersに移動させる
  def backup_followers
    self.before_followers.delete_all
    self.followers.each do |follower|
      self.before_followers << BeforeFollower.new(user: self, uid: follower.uid, name: follower.name, screen_name: follower.screen_name)
    end
  end

  # DM連絡
  def send_dm(client, url = Settings.system[:url])
      if option.try(:dm_msg_flg)
        new_followers = Follower.new_followers(self)
        change_name_followers = Follower.change_name_followers(self)
        change_screen_name_followers = Follower.change_screen_name_followers(self)
        remove_followers = BeforeFollower.remove_followers(self)

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
        msg += "\r\n詳細はログインしてご確認ください。\r\n#{url}"

        client.create_direct_message(uid, msg)
      end
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_API_KEY"]
        config.consumer_secret     = ENV["TWITTER_SECRET_KEY"]
        config.access_token        = access_token
        config.access_token_secret = access_token_secret
    end
  end

end
