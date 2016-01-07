require 'rails_helper'

RSpec.describe "WorldSurveys", type: :request do
  describe "GET /world_surveys" do
    it "works! (now write some real specs)" do
      get world_surveys_path
      expect(response).to have_http_status(200)
    end
  end
end
