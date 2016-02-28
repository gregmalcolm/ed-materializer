require 'rails_helper'
require 'support/helpers/auth_helper.rb'

describe Api::V2::SiteSurveysController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include BasecampsHelper
  include SiteSurveysHelper
  include Devise::TestHelpers
  
  def combined_attrs(attributes, basecamp_id) 
    attributes.merge(basecamp_id: basecamp_id)
  end

  let!(:worlds) { spawn_worlds }
  let!(:basecamps) { spawn_basecamps(world1: worlds[0], world2: worlds[1]) }
  let!(:site_surveys) { spawn_site_surveys(basecamp1: basecamps[0], basecamp2: basecamps[1]) }
  let!(:users) { spawn_users }
  let(:auth_tokens) { sign_in users[:edd]}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:site_surveys_json) { json["site_surveys"] }
    let(:commanders) { site_surveys_json.map { |j| j["commander"] } }

    context "drinking from the firehouse" do
      before { get :index, {basecamp_id: basecamps[0].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(site_surveys_json[1]["commander"]).to be == "Mwerle" }
      it { expect(site_surveys_json.size).to be >= 2 }
    end

    describe "filtering" do
      context "on basecamp_id" do
        before { get :index, {basecamp_id: basecamps[1].id} }
        it { expect(site_surveys_json[0]["commander"]).to be == "Michael Darkmoor" }
        it { expect(site_surveys_json.size).to be == 1 }
      end
      
      context "on commander" do
        before { get :index, {basecamp_id: basecamps[0].id, 
                              commander: "  Eoran "} }
        it { expect(site_surveys_json[0]["resource"]).to be == "Bronzite Chondrite" }
        it { expect(site_surveys_json.size).to be == 1 }
      end
      
      context "resource" do
        before { get :index, {basecamp_id: basecamps[1].id, 
                              resource: "AGGREGATED"} }
        it { expect(site_surveys_json[0]["commander"]).to be == "Michael Darkmoor" }
        it { expect(site_surveys_json.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, updated_before: Time.now - 3.days}
        it { expect(commanders).to include "Eoran" }
        it { expect(commanders).to include "Mwerle" }
        it { expect(site_surveys_json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, updated_after: Time.now - 3.days}
        it { expect(commanders).to include "Michael Darkmoor" }
        it { expect(site_surveys_json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:site_survey) { json["site_survey"] }
    context "nested" do
      before { get :show, {id: site_surveys[2].id,
                           basecamp_id: basecamps[1].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(site_survey["commander"]).to be == "Michael Darkmoor" }
    end

    context "not nested" do
      before { get :show, {id: site_surveys[2].id } }
      it { expect(response).to have_http_status(200) }
      it { expect(site_survey["commander"]).to be == "Michael Darkmoor" }
    end
  end

  describe "POST #create" do
    let(:site_survey_json) { json["site_survey"] }
    let(:new_site_survey) { {
      resource: "Outcrop 1", 
      commander: "Marvin", 
      tin: 4,
      niobium: 5}
    }

    context "adding a site_survey" do
      before { get :create, { basecamp_id: basecamps[1].id, 
                              site_survey: new_site_survey }, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(site_survey_json["resource"]).to be == "Outcrop 1" }
      it { expect(SiteSurvey.last.commander).to be == "Marvin" }
    end

    context "unauthorized" do
      before { post :create, { basecamp_id: basecamps[1].id, 
                               site_survey: new_site_survey } }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_site_survey) { { basecamp_id: basecamps[0].id,
                                  id: site_surveys[1].id,
                                  site_survey: {mercury: 51 } } }
    context "updating a site_survey" do
      before { put :update, updated_site_survey, auth_tokens }
      let(:site_survey) { SiteSurvey.find(site_surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(site_survey.commander).to be == "Mwerle" }
      it { expect(site_survey.mercury).to be 51 }
    end

    context "not nested" do
      let(:updated_site_survey) { { id: site_surveys[1].id,
                                    site_survey: { basecamp_id: basecamps[0].id, 
                                                   polonium: 5 } } }
      before { put :update, updated_site_survey, auth_tokens }
      let(:site_survey) { SiteSurvey.find(site_surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(site_survey.polonium).to be 5 }
    end

    context "unauthenticated" do
      before { put :update, updated_site_survey }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    context "authorized power user" do
      let(:id) { site_surveys[0].id }
      before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
      it { expect(SiteSurvey.where(id: id).any?).to be false }
    end
    
    context "unauthenticated" do
      let(:id) { site_surveys[0].id }

      before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized basic user" do
      let(:id) { site_surveys[0].id }
      let(:auth_tokens) { sign_in users[:marlon]}
      before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end
end
