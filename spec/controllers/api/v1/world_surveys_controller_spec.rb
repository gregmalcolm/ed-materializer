require 'rails_helper'
require 'support/helpers/world_surveys_helper.rb'

describe Api::V1::WorldSurveysController, type: :controller do
  include WorldSurveysHelper

  let(:valid_session) { {} }
  let!(:surveys) { spawn_world_surveys }

  describe "GET #index" do
    let(:json) { JSON.parse(response.body)["world_surveys"] }

    before { get :index, {}, valid_session }
    it { expect(response).to have_http_status(200) }
    it { expect(json[0]["system"]).to be == "NGANJI" }
    it { expect(json.size).to be >= 3 }
  end

  describe "GET #show" do
    let(:json) { JSON.parse(response.body)["world_survey"] }

    before { get :show, {id: surveys[1].id}, valid_session }
    it { expect(response).to have_http_status(200) }
    it { expect(json["system"]).to be == "SHINRARTA DEZHRA" }
    it { expect(json["commander"]).to be == "Dommaarraa" }
  end

  describe "POST #create" do
    let(:json) { JSON.parse(response.body)["world_survey"] }

    let(:new_survey) { { world_survey:
      { system: "MAGRATHEA", commander: "Arthur Dent", world: "B 2", zinc: true } }
    }

    context "adding a survey" do
      before { post :create, new_survey, valid_session }
      it { expect(response).to have_http_status(201) }
      it { expect(json["system"]).to be == "MAGRATHEA" }
      it { expect(WorldSurvey.last.system).to be == "MAGRATHEA" }
    end

    context "Trying to add a servey that already exists" do
      before { create :world_survey, new_survey[:world_survey] }
      before { post :create, new_survey, valid_session }
      it { expect(response).to have_http_status(422) }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_survey) { { id: surveys[0].id,
                             world_survey: { mercury: true }} }
    context "updating a survey" do
      before { put :update, updated_survey, valid_session }
      let(:survey) { WorldSurvey.find(surveys[0].id) }
      it { expect(response).to have_http_status(204) }
      it { expect(survey.system).to be == "NGANJI" }
      it { expect(survey.mercury).to be true }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { surveys[0].id }
    before { delete :destroy, {id: id}, valid_session }
    it { expect(response).to have_http_status(204) }
    it { expect(WorldSurvey.where(id: id).any?).to be false }
  end
end
