require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/star_surveys_helper.rb'

describe Api::V1::StarSurveysController, type: :controller do
  include AuthHelper
  include StarSurveysHelper
  include Devise::TestHelpers

  let!(:surveys) { spawn_star_surveys }
  let!(:users) { spawn_users }
  let(:auth_tokens) { sign_in users[:edd]}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:star_surveys) { json["star_surveys"] }
    let(:commanders) { star_surveys.map { |j| j["commander"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(star_surveys[1]["system"]).to be == "Hoth" }
      it { expect(star_surveys.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {q: {system: " hoth "}} }
        it { expect(star_surveys[0]["system"]).to be == "Hoth" }
        it { expect(star_surveys.size).to be == 1 }
      end

      context "on commander" do
        before { get :index, {q: {commander: "  robbyxp1"}} }
        it { expect(star_surveys[0]["system"]).to be == "ALDERAAN" }
        it { expect(star_surveys.size).to be == 1 }
      end

      context "on star" do
        before { get :index, {q: {star: "b"}} }
        it { expect(star_surveys[0]["system"]).to be == "ALDERAAN" }
        it { expect(star_surveys.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, {q: {updated_before: Time.now - 3.days}} }
        it { expect(commanders).to include "Cruento Mucrone" }
        it { expect(commanders).to include "Zed" }
        it { expect(star_surveys.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {q: {updated_after: Time.now - 3.days}} }
        it { expect(commanders).to include "robbyxp1" }
        it { expect(star_surveys.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:star_survey) { json["star_survey"] }

    before { get :show, {id: surveys[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(star_survey["system"]).to be == "ALDERAAN" }
    it { expect(star_survey["commander"]).to be == "robbyxp1" }
  end

  describe "POST #create" do
    let(:star_survey) { json["star_survey"] }
    let(:new_survey) { { star_survey:
      { system: "Magrathea", commander: "Ford Prefect", star: "", star_age: 50000.5 } }
    }

    context "adding a survey" do
      before { post :create, new_survey, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(star_survey["system"]).to be == "Magrathea" }
      it { expect(StarSurvey.last.system).to be == "Magrathea" }
    end

    context "allows one survey per commander per star" do
      before { create :star_survey, new_survey[:star_survey] }
      before { post :create, new_survey, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["star"]).to include "has already been taken for this system and commander" }
    end

    context "rejects blanks in key fields" do
      before { post :create, {star_survey: {surface_temp: 44}}, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["commander"]).to include "can't be blank" }
      it { expect(json["system"]).to include "can't be blank" }
      it { expect(json["star"]).to_not include "can't be blank" }
    end

    context "adding a survey updates every field" do
      let(:full_attributes) { attributes_for(:star_survey, :full) }
      let(:new_survey) { {star_survey: full_attributes} }
      before { post :create, new_survey, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(star_survey.values).to_not include be_blank }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_survey) { { star_survey:
        { system: "MAGRATHEA", commander: "fORD pREFECT", star: "", note: "Again!" } }
      }

      before { create :star_survey, new_survey[:star_survey] }
      before { post :create, clashing_survey, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["star"]).to include "has already been taken for this system and commander" }
    end

    context "unauthorized" do
      before { post :create, new_survey }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_survey) { { id: surveys[1].id,
                             star_survey: { solar_mass: 3.14 }} }
    context "updating a survey" do
      before { put :update, updated_survey, auth_tokens }
      let(:survey) { StarSurvey.find(surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(survey.system).to be == "Hoth" }
      it { expect(survey.solar_mass).to be 3.14 }
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

    context "unauthorized banned user" do
      let(:id) { surveys[0].id }
      let(:auth_tokens) { sign_in users[:banned]}
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "authorized power user" do
      let(:id) { surveys[0].id }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
      it { expect(StarSurvey.where(id: id).any?).to be false }
    end
  end
end
