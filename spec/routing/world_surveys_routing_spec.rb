require "rails_helper"

RSpec.describe WorldSurveysController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/world_surveys").to route_to("world_surveys#index")
    end

    it "routes to #new" do
      expect(:get => "/world_surveys/new").to route_to("world_surveys#new")
    end

    it "routes to #show" do
      expect(:get => "/world_surveys/1").to route_to("world_surveys#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/world_surveys/1/edit").to route_to("world_surveys#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/world_surveys").to route_to("world_surveys#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/world_surveys/1").to route_to("world_surveys#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/world_surveys/1").to route_to("world_surveys#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/world_surveys/1").to route_to("world_surveys#destroy", :id => "1")
    end

  end
end
