require 'rails_helper'

describe Api::V1::WorldSurveysController, type: :controller do

  let(:valid_attributes) {
    {
      system: "Void's Brink",
      commander: "Alex Ryder",
      world: "A 1",
      zinc: true
    }
  }

  let(:invalid_attributes) {
    { id: 42 }
  }

  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all world_surveys as @world_surveys" do
      world_survey = WorldSurvey.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:world_surveys)).to eq([world_survey])
    end
  end

  describe "GET #show" do
    it "assigns the requested world_survey as @world_survey" do
      world_survey = WorldSurvey.create! valid_attributes
      get :show, {:id => world_survey.to_param}, valid_session
      expect(assigns(:world_survey)).to eq(world_survey)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new WorldSurvey" do
        expect {
          post :create, {:world_survey => valid_attributes}, valid_session
        }.to change(WorldSurvey, :count).by(1)
      end

      it "assigns a newly created world_survey as @world_survey" do
        post :create, {:world_survey => valid_attributes}, valid_session
        expect(assigns(:world_survey)).to be_a(WorldSurvey)
        expect(assigns(:world_survey)).to be_persisted
      end

      it "responds to created world_survey with a success code" do
        post :create, {:world_survey => valid_attributes}, valid_session
        expect(response.code).to eq("201")
      end
    end

    context "with invalid params" do
      #it "responds to invalid create params a fail code" do
        #post :create, {:world_survey => invalid_attributes}, valid_session
        #expect(response.code).to eq("401")
      #end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          system: "Void's Brink",
          commander: "Alex Ryder",
          world: "B 2",
          polonium: true,
          iron: true,
          zinc: false
        }
      }

      it "assigns the requested world_survey as @world_survey" do
        world_survey = WorldSurvey.create! valid_attributes
        put :update, {:id => world_survey.to_param, :world_survey => valid_attributes}, valid_session
        expect(assigns(:world_survey)).to eq(world_survey)
      end

      it "responds with a success code for a valid record" do
        world_survey = WorldSurvey.create! valid_attributes
        put :update, {:id => world_survey.to_param, :world_survey => valid_attributes}, valid_session
        expect(response.code).to eq("204")
      end
    end

    context "with invalid params" do
      it "assigns the world_survey as @world_survey" do
        world_survey = WorldSurvey.create! valid_attributes
        put :update, {:id => world_survey.to_param, :world_survey => invalid_attributes}, valid_session
        expect(assigns(:world_survey)).to eq(world_survey)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested world_survey" do
      world_survey = WorldSurvey.create! valid_attributes
      expect {
        delete :destroy, {:id => world_survey.to_param}, valid_session
      }.to change(WorldSurvey, :count).by(-1)
    end

    it "responds to a deletion with the exepected code" do
      world_survey = WorldSurvey.create! valid_attributes
      delete :destroy, {:id => world_survey.to_param}, valid_session
      expect(response.code).to eq("204")
    end
  end

end
