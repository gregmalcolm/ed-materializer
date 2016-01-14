require 'rails_helper'
require 'support/helpers/world_surveys_helper.rb'

describe Api::V1::WorldSurveysController, type: :controller do
  include WorldSurveysHelper

  let(:valid_session) { {} }
  let!(:surveys) { spawn_world_surveys }

  describe "GET #index" do
    let(:json) { JSON.parse(response.body)["world_surveys"] }
    let(:commanders) { json.map { |j| j["commander"] } }

    context "drinking from the firehouse" do
      before { get :index, {}, valid_session }
      it { expect(response).to have_http_status(200) }
      it { expect(json[1]["system"]).to be == "NGANJI" }
      it { expect(json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {q: {system: " nganjI "}}, valid_session }
        it { expect(json[0]["system"]).to be == "NGANJI" }
        it { expect(json.size).to be == 1 }
      end

      context "on commander" do
        before { get :index, {q: {commander: "  DOMMAARRAA"}}, valid_session }
        it { expect(json[0]["system"]).to be == "SHINRARTA DEZHRA" }
        it { expect(json.size).to be == 1 }
      end

      context "on world" do
        before { get :index, {q: {world: "a 5 "}}, valid_session }
        it { expect(json[0]["system"]).to be == "SHINRARTA DEZHRA" }
        it { expect(json.size).to be == 2 }
      end

      context "on updated_before" do
        before { get :index, {q: {updated_before: Time.now - 3.days}}, valid_session }
        it { expect(commanders).to include "Finwen" }
        it { expect(commanders).to include "Marlon Blake" }
        it { expect(json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {q: {updated_after: Time.now - 3.days}}, valid_session }
        it { expect(commanders).to include "Dommaarraa" }
        it { expect(json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:json) { JSON.parse(response.body)["world_survey"] }

    before { get :show, {id: surveys[2].id}, valid_session }
    it { expect(response).to have_http_status(200) }
    it { expect(json["system"]).to be == "SHINRARTA DEZHRA" }
    it { expect(json["commander"]).to be == "Dommaarraa" }
  end

  describe "POST #create" do
    let(:json) { JSON.parse(response.body) }

    let(:new_survey) { { world_survey:
      { system: "MAGRATHEA", commander: "Arthur Dent", world: "B 2", zinc: true } }
    }

    context "adding a survey" do
      before { post :create, new_survey, valid_session }
      it { expect(response).to have_http_status(201) }
      it { expect(json["world_survey"]["system"]).to be == "MAGRATHEA" }
      it { expect(WorldSurvey.last.system).to be == "MAGRATHEA" }
    end

    context "one survey per commander per world" do
      before { create :world_survey, new_survey[:world_survey] }
      before { post :create, new_survey, valid_session }
      it { expect(response).to have_http_status(422) }
      it { expect(json["commander"]).to include "has already been taken" }
    end

    context "adding a survey" do
      before { post :create, {world_survey: {tin: true}}, valid_session }
      it { expect(response).to have_http_status(422) }
      it { expect(json["commander"]).to include "can't be blank" }
      it { expect(json["system"]).to include "can't be blank" }
      it { expect(json["world"]).to include "can't be blank" }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_survey) { { id: surveys[1].id,
                             world_survey: { mercury: true }} }
    context "updating a survey" do
      before { put :update, updated_survey, valid_session }
      let(:survey) { WorldSurvey.find(surveys[1].id) }
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
