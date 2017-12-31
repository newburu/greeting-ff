require 'rails_helper'

RSpec.describe "BeforeFollowers", type: :request do
  describe "GET /before_followers" do
    it "works! (now write some real specs)" do
      get before_followers_path
      expect(response).to have_http_status(200)
    end
  end
end
