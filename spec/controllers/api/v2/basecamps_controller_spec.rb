require 'rails_helper'
require 'support/helpers/auth_helper.rb'

describe Api::V2::BasecampsController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include BasecampsHelper
  include Devise::TestHelpers

  let!(:worlds) { spawn_worlds }
  let!(:basecamps) { spawn_basecamps(world1: worlds[0], world2: worlds[1]) }
  let!(:users) { spawn_users }
  let(:auth_tokens) { sign_in users[:edd]}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:basecamps_json) { json["basecamps"] }
    let(:updaters) { basecamps_json.map { |j| j["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {world_id: worlds[0].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(basecamps_json[1]["name"]).to be == "FGE BC2" }
      it { expect(basecamps_json.size).to be >= 2 }
    end

    #describe "filtering" do
      #context "on system" do
        #before { get :index, {system: " hoth "} }
        #it { expect(basecamps_json[0]["system"]).to be == "Hoth" }
        #it { expect(basecamps_json.size).to be == 1 }
      #end

      #context "on updater" do
        #before { get :index, {updater: "  robbyxp1"} }
        #it { expect(basecamps_json[0]["system"]).to be == "ALDERAAN" }
        #it { expect(basecamps_json.size).to be == 1 }
      #end

      #context "on basecamp" do
        #before { get :index, {basecamp: "b"} }
        #it { expect(basecamps_json[0]["system"]).to be == "ALDERAAN" }
        #it { expect(basecamps_json.size).to be == 1 }
      #end

      #context "on updated_before" do
        #before { get :index, {updated_before: Time.now - 3.days} }
        #it { expect(updaters).to include "Cruento Mucrone" }
        #it { expect(updaters).to include "Zed" }
        #it { expect(basecamps_json.size).to be == 2 }
      #end

      #context "on updated_after" do
        #before { get :index, {updated_after: Time.now - 3.days} }
        #it { expect(updaters).to include "robbyxp1" }
        #it { expect(basecamps_json.size).to be == 1 }
      #end
    #end
  end

  #describe "GET #show" do
    #let(:basecamp) { json["basecamp"] }

    #before { get :show, {id: basecamps[2].id} }
    #it { expect(response).to have_http_status(200) }
    #it { expect(basecamp["system"]).to be == "ALDERAAN" }
    #it { expect(basecamp["updater"]).to be == "robbyxp1" }
  #end

  #describe "POST #create" do
    #let(:basecamp) { json["basecamp"] }
    #let(:new_basecamp) { { basecamp:
      #{ system: "Magrathea", updater: "Ford Prefect", basecamp: "", basecamp_age: 50000.5 } }
    #}

    #context "adding a basecamp" do
      #before { post :create, new_basecamp, auth_tokens }
      #it { expect(response).to have_http_status(201) }
      #it { expect(basecamp["system"]).to be == "Magrathea" }
      #it { expect(basecamp.last.system).to be == "Magrathea" }
    #end

    #context "allows one record per basecamp" do
      #before { create :basecamp, new_basecamp[:basecamp] }
      #before { post :create, new_basecamp, auth_tokens }
      #it { expect(response).to have_http_status(422) }
      #it { expect(json["basecamp"]).to include "has already been taken for this system" }
    #end

    #context "rejects blanks in key fields" do
      #before { post :create, {basecamp: {surface_temp: 44}}, auth_tokens }
      #it { expect(response).to have_http_status(422) }
      #it { expect(json["updater"]).to include "can't be blank" }
      #it { expect(json["system"]).to include "can't be blank" }
      #it { expect(json["basecamp"]).to_not include "can't be blank" }
    #end

    #context "adding a basecamp updates every field" do
      #let(:full_attributes) { attributes_for(:basecamp, :full) }
      #let(:new_basecamp) { {basecamp: full_attributes} }
      #before { post :create, new_basecamp, auth_tokens }
      #it { expect(response).to have_http_status(201) }
      #it { expect(basecamp.values).to_not include be_blank }
    #end

    #context "when checking for clashing systems, take into account casing" do
      #let(:clashing_basecamp) { { basecamp:
        #{ system: "MAGRATHEA", updater: "fORD pREFECT", basecamp: "", notes: "Again!" } }
      #}

      #before { create :basecamp, new_basecamp[:basecamp] }
      #before { post :create, clashing_basecamp, auth_tokens }
      #it { expect(response).to have_http_status(422) }
      #it { expect(json["basecamp"]).to include "has already been taken for this system" }
    #end

    #context "unauthorized" do
      #before { post :create, new_basecamp }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end
  #end

  #describe "PATCH/PUT #update" do
    #let(:updated_basecamp) { { id: basecamps[1].id,
                             #basecamp: { solar_mass: 3.14 }} }
    #context "updating a basecamp" do
      #before { put :update, updated_basecamp, auth_tokens }
      #let(:basecamp) { basecamp.find(basecamps[1].id)}
      #it { expect(response).to have_http_status(204) }
      #it { expect(basecamp.system).to be == "Hoth" }
      #it { expect(basecamp.solar_mass).to be 3.14 }
    #end

    #context "unauthenticated" do
      #before { put :update, updated_basecamp }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end
  #end

  #describe "DELETE #destroy" do
    #context "unauthenticated" do
      #let(:id) { basecamps[0].id }
      #before { delete :destroy, {id: id} }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end

    #context "unauthorized basic user" do
      #let(:id) { basecamps[0].id }
      #let(:auth_tokens) { sign_in users[:marlon]}
      #before { delete :destroy, {id: id}, auth_tokens }
      #it { expect(response).to have_http_status(401) }
      #it { expect(json["errors"]).to include "Authorized users only." }
    #end

    #context "authorized power user" do
      #let(:id) { basecamps[0].id }
      #before { delete :destroy, {id: id}, auth_tokens }
      #it { expect(response).to have_http_status(204) }
      #it { expect(basecamp.where(id: id).any?).to be false }
    #end
  #end
end
