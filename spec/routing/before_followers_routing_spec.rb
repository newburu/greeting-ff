require "rails_helper"

RSpec.describe BeforeFollowersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/before_followers").to route_to("before_followers#index")
    end

    it "routes to #new" do
      expect(:get => "/before_followers/new").to route_to("before_followers#new")
    end

    it "routes to #show" do
      expect(:get => "/before_followers/1").to route_to("before_followers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/before_followers/1/edit").to route_to("before_followers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/before_followers").to route_to("before_followers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/before_followers/1").to route_to("before_followers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/before_followers/1").to route_to("before_followers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/before_followers/1").to route_to("before_followers#destroy", :id => "1")
    end

  end
end
