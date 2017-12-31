class BeforeFollowersController < InheritedResources::Base

  private

    def before_follower_params
      params.require(:before_follower).permit(:user_id, :uid, :name, :screen_name)
    end
end

