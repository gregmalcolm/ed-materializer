require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/world_surveys_v1_helper.rb'

describe Api::V2::WorldSurveysController, type: :controller do
  include AuthHelper
  include WorldSurveysV1Helper
  include Devise::TestHelpers

  let!(:surveys) { spawn_world_surveys }
  let!(:users) { spawn_users }
  let(:auth_tokens) { sign_in users[:edd]}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:world_surveys) { json["world_surveys"] }
    let(:commanders) { world_surveys.map { |j| j["commander"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(world_surveys[1]["system"]).to be == "NGANJI" }
      it { expect(world_surveys.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {system: " nganjI "} }
        it { expect(world_surveys[0]["system"]).to be == "NGANJI" }
        it { expect(world_surveys.size).to be == 1 }
      end

      context "on commander" do
        before { get :index, {commander: "  DOMMAARRAA"} }
        it { expect(world_surveys[0]["system"]).to be == "SHINRARTA DEZHRA" }
        it { expect(world_surveys.size).to be == 1 }
      end

      context "on world" do
        before { get :index, {world: "a 5 "} }
        it { expect(world_surveys[0]["system"]).to be == "SHINRARTA DEZHRA" }
        it { expect(world_surveys.size).to be == 2 }
      end

      context "on updated_before" do
        before { get :index, {updated_before: Time.now - 3.days} }
        it { expect(commanders).to include "Finwen" }
        it { expect(commanders).to include "Marlon Blake" }
        it { expect(world_surveys.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {updated_after: Time.now - 3.days} }
        it { expect(commanders).to include "Dommaarraa" }
        it { expect(world_surveys.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:world_survey) { json["world_survey"] }

    before { get :show, {id: surveys[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(world_survey["system"]).to be == "SHINRARTA DEZHRA" }
    it { expect(world_survey["commander"]).to be == "Dommaarraa" }
  end

  describe "POST #create" do
    let(:world_survey) { json["world_survey"] }
    let(:new_survey) { { world_survey:
      { system: "Magrathea", commander: "Arthur Dent", world: "B 2", zinc: true } }
    }

    context "adding a survey" do
      before { post :create, new_survey, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(world_survey["system"]).to be == "Magrathea" }
      it { expect(WorldSurveyV1.last.system).to be == "Magrathea" }
    end

    context "allows one survey per commander per world" do
      before { create :world_survey_v1, new_survey[:world_survey] }
      before { post :create, new_survey, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["world"]).to include "has already been taken for this system and commander" }
    end

    context "rejects blanks in key fields" do
      before { post :create, {world_survey: {tin: true}}, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["commander"]).to include "can't be blank" }
      it { expect(json["system"]).to include "can't be blank" }
      it { expect(json["world"]).to include "can't be blank" }
    end

    context "adding a survey updates every field" do
      let(:full_attributes) { attributes_for(:world_survey_v1, :full) }
      let(:new_survey) { {world_survey: full_attributes} }
      before { post :create, new_survey, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(world_survey.values).to_not include be_blank }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_survey) { { world_survey:
        { system: "MAGRATHEA", commander: "ARTHUR DENT", world: "b 2", tin: true } }
      }

      before { create :world_survey_v1, new_survey[:world_survey] }
      before { post :create, clashing_survey, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["world"]).to include "has already been taken for this system and commander" }
    end

    context "unauthorized" do
      before { post :create, new_survey }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_survey) { { id: surveys[1].id,
                             world_survey: { mercury: true }} }
    context "updating a survey" do
      before { put :update, updated_survey, auth_tokens }
      let(:survey) { WorldSurveyV1.find(surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(survey.system).to be == "NGANJI" }
      it { expect(survey.mercury).to be true }
    end

    context "unauthenticated" do
      before { put :update, updated_survey }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    context "unauthenticated" do
      let(:id) { surveys[0].id }
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized basic user" do
      let(:id) { surveys[0].id }
      let(:auth_tokens) { sign_in users[:marlon]}
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "authorized power user" do
      let(:id) { surveys[0].id }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
      it { expect(WorldSurveyV1.where(id: id).any?).to be false }
    end
  end
end
