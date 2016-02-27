require 'rails_helper'
require 'support/helpers/auth_helper.rb'

describe Api::V2::BasecampsController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include BasecampsHelper
  include Devise::TestHelpers
  
  def combined_attrs(attributes, world_id) 
    attributes.merge(world_id: world_id)
  end

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

    describe "filtering" do
      context "on name" do
        before { get :index, {world_id: worlds[0].id, 
                              name: " fge BC2"} }
        it { expect(basecamps_json[0]["name"]).to be == "FGE BC2" }
        it { expect(basecamps_json.size).to be == 1 }
      end

      context "on updater" do
        before { get :index, {world_id: worlds[0].id, 
                              updater: "  nexOlek "} }
        it { expect(basecamps_json[0]["name"]).to be == "FGE BC1" }
        it { expect(basecamps_json.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, {world_id: worlds[0].id, 
                              updated_before: Time.now - 8.days} }
        it { expect(updaters).to include "Nexolek" }
        it { expect(basecamps_json.size).to be == 1 }
      end

      context "on updated_after" do
        before { get :index, {world_id: worlds[0].id, 
                              updated_after: Time.now - 8.days} }
        it { expect(updaters).to include "Anthor" }
        it { expect(basecamps_json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:basecamp) { json["basecamp"] }

    before { get :show, {id: basecamps[2].id, 
                         world_id: worlds[1].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(basecamp["name"]).to be == "Dark Fortress" }
    it { expect(basecamp["updater"]).to be == "Majkl578" }
  end

  describe "POST #create" do
    let(:basecamp_json) { json["basecamp"] }
    let(:new_basecamp) { {
      name: "Mouse House", 
      updater: "Trillion Maximillion", 
      landing_zone_lat: 42.0, 
      landing_zone_lon: -42.0}
    }

    context "adding a basecamp" do
      before { get :create, { world_id: worlds[1].id, 
                              basecamp: new_basecamp }, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(basecamp_json["name"]).to be == "Mouse House" }
      it { expect(Basecamp.last.name).to be == "Mouse House" }
    end

    context "allows one record per basecamp" do
      let!(:existing_basecamp) { 
        create :basecamp, combined_attrs(new_basecamp, worlds[1].id) 
      }
      before { get :create, { world_id: worlds[1].id, 
                              basecamp: new_basecamp }, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["basecamp"][0]).to match(/has already been taken/) }
    end
    
    context "expects a world id" do
      before { expect { get :create, { basecamp: new_basecamp }, auth_tokens
                      }.to raise_error(RoutingError)
             }
    end

    context "rejects blanks in key fields" do
      before { get :create, { world_id: worlds[1].id, 
                              basecamp: {terrain_hue_1: 128} }, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["name"]).to include "can't be blank" }
      it { expect(json["updater"]).to include "can't be blank" }
    end

    context "when checking for clashing names, take into account casing" do
      let(:clashing_basecamp) {
        { name: "MOUSE house", updater: "Zaphod", notes: "First!" }
      }

      let!(:existing_basecamp) { create :basecamp, combined_attrs(new_basecamp, worlds[1].id) }
      before { post :create, { world_id: worlds[1].id, 
                              basecamp: clashing_basecamp }, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["basecamp"][0]).to match(/has already been taken/) }
    end

    context "unauthorized" do
      before { post :create, { world_id: worlds[1].id, 
                               basecamp: new_basecamp } }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_basecamp) { { world_id: worlds[0].id,
                               id: basecamps[1].id,
                               basecamp: {terrain_hue_1: 512 } } }
    context "updating a basecamp" do
      before { put :update, updated_basecamp, auth_tokens }
      let(:basecamp) { Basecamp.find(basecamps[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(basecamp.name).to be == "FGE BC2" }
      it { expect(basecamp.terrain_hue_1).to be 512 }
    end

    context "unauthenticated" do
      before { put :update, updated_basecamp }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    context "authorized power user" do
      let(:id) { basecamps[0].id }
      before { delete :destroy, {world_id: worlds[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
      it { expect(Basecamp.where(id: id).any?).to be false }
    end
    
    context "unauthenticated" do
      let(:id) { basecamps[0].id }

      before { delete :destroy, {world_id: worlds[0].id,
                                 id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized basic user" do
      let(:id) { basecamps[0].id }
      let(:auth_tokens) { sign_in users[:marlon]}
      before { delete :destroy, {world_id: worlds[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end
end
