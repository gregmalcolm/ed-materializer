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
    let(:updaters) { site_surveys_json.map { |j| j["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {basecamp_id: basecamps[0].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(site_surveys_json[1]["commander"]).to be == "Mwerle" }
      it { expect(site_surveys_json.size).to be >= 2 }
    end

    #describe "filtering" do
      #context "on name" do
        #before { get :index, {basecamp_id: basecamps[0].id, 
                              #name: " fge BC2"} }
        #it { expect(site_surveys_json[0]["name"]).to be == "FGE BC2" }
        #it { expect(site_surveys_json.size).to be == 1 }
      #end

      #context "on updater" do
        #before { get :index, {basecamp_id: basecamps[0].id, 
                              #updater: "  nexOlek "} }
        #it { expect(site_surveys_json[0]["name"]).to be == "FGE BC1" }
        #it { expect(site_surveys_json.size).to be == 1 }
      #end

      #context "on updated_before" do
        #before { get :index, {basecamp_id: basecamps[0].id, 
                              #updated_before: Time.now - 8.days} }
        #it { expect(updaters).to include "Nexolek" }
        #it { expect(site_surveys_json.size).to be == 1 }
      #end

      #context "on updated_after" do
        #before { get :index, {basecamp_id: basecamps[0].id, 
                              #updated_after: Time.now - 8.days} }
        #it { expect(updaters).to include "Anthor" }
        #it { expect(site_surveys_json.size).to be == 1 }
      #end
    #end
  end

  #describe "GET #show" do
    #let(:site_survey) { json["site_survey"] }

    #before { get :show, {id: site_surveys[2].id, 
                         #basecamp_id: basecamps[1].id} }
    #it { expect(response).to have_http_status(200) }
    #it { expect(site_survey["name"]).to be == "Dark Fortress" }
    #it { expect(site_survey["updater"]).to be == "Majkl578" }
  #end

  #describe "POST #create" do
    #let(:site_survey_json) { json["site_survey"] }
    #let(:new_site_survey) { {
      #name: "Mouse House", 
      #updater: "Trillion Maximillion", 
      #landing_zone_lat: 42.0, 
      #landing_zone_lon: -42.0}
    #}

    #context "adding a site_survey" do
      #before { get :create, { basecamp_id: basecamps[1].id, 
                              #site_survey: new_site_survey }, auth_tokens }
      #it { expect(response).to have_http_status(201) }
      #it { expect(site_survey_json["name"]).to be == "Mouse House" }
      #it { expect(SiteSurvey.last.name).to be == "Mouse House" }
    #end

    #context "allows one record per site_survey" do
      #let!(:existing_site_survey) { 
        #create :site_survey, combined_attrs(new_site_survey, basecamps[1].id) 
      #}
      #before { get :create, { basecamp_id: basecamps[1].id, 
                              #site_survey: new_site_survey }, auth_tokens }
      #it { expect(response).to have_http_status(422) }
      #it { expect(json["site_survey"][0]).to match(/has already been taken/) }
    #end
    
    #context "expects a basecamp id" do
      #before { expect { get :create, { site_survey: new_site_survey }, auth_tokens
                      #}.to raise_error(RoutingError)
             #}
    #end

    #context "rejects blanks in key fields" do
      #before { get :create, { basecamp_id: basecamps[1].id, 
                              #site_survey: {terrain_hue_1: 128} }, auth_tokens }
      #it { expect(response).to have_http_status(422) }
      #it { expect(json["name"]).to include "can't be blank" }
      #it { expect(json["updater"]).to include "can't be blank" }
    #end
    
    #context "adding a site_survey which updates every field" do
      #let(:full_attributes) { attributes_for(:site_survey, :full) }
      #let(:new_survey) { {site_survey: full_attributes} }
      #before { post :create, new_survey, auth_tokens }
      #it { expect(response).to have_http_status(201) }
      #it { expect(site_survey.values).to_not include be_blank }
    #end

    #context "when checking for clashing names, take into account casing" do
      #let(:clashing_site_survey) {
        #{ name: "MOUSE house", updater: "Zaphod", notes: "First!" }
      #}

      #let!(:existing_site_survey) { create :site_survey, combined_attrs(new_site_survey, basecamps[1].id) }
      #before { post :create, { basecamp_id: basecamps[1].id, 
                              #site_survey: clashing_site_survey }, auth_tokens }
      #it { expect(response).to have_http_status(422) }
      #it { expect(json["site_survey"][0]).to match(/has already been taken/) }
    #end

    #context "unauthorized" do
      #before { post :create, { basecamp_id: basecamps[1].id, 
                               #site_survey: new_site_survey } }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end
  #end

  #describe "PATCH/PUT #update" do
    #let(:updated_site_survey) { { basecamp_id: basecamps[0].id,
                               #id: site_surveys[1].id,
                               #site_survey: {terrain_hue_1: 512 } } }
    #context "updating a site_survey" do
      #before { put :update, updated_site_survey, auth_tokens }
      #let(:site_survey) { SiteSurvey.find(site_surveys[1].id)}
      #it { expect(response).to have_http_status(204) }
      #it { expect(site_survey.name).to be == "FGE BC2" }
      #it { expect(site_survey.terrain_hue_1).to be 512 }
    #end

    #context "unauthenticated" do
      #before { put :update, updated_site_survey }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end
  #end

  #describe "DELETE #destroy" do
    #context "authorized power user" do
      #let(:id) { site_surveys[0].id }
      #before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 #id: id}, auth_tokens }
      #it { expect(response).to have_http_status(204) }
      #it { expect(SiteSurvey.where(id: id).any?).to be false }
    #end
    
    #context "unauthenticated" do
      #let(:id) { site_surveys[0].id }

      #before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 #id: id} }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end

    #context "unauthorized basic user" do
      #let(:id) { site_surveys[0].id }
      #let(:auth_tokens) { sign_in users[:marlon]}
      #before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 #id: id}, auth_tokens }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end
  #end
end
