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
                          password: Devise.friendly_token[0,20]
                          )
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

end
