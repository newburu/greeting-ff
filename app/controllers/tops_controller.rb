class TopsController < ApplicationController
  def show
    @user = User.find_by(name: params[:name])
  end
  
  def index
    if current_user.present?
      redirect_to followers_path
    else
      redirect_to static_pages_info_url
    end
  end
  
end
