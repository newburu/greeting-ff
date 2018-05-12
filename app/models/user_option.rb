class UserOption < ApplicationRecord
  belongs_to :user
  
  validates :auto_follow_msg, presence: true, if: :auto_follow_msg_flg?

end
