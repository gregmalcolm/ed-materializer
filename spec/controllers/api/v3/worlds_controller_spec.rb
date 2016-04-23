require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/worlds_helper.rb'

describe Api::V3::WorldsController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include Devise::TestHelpers

  let!(:worlds) { spawn_worlds }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)["data"]}
  let(:json_errors) { JSON.parse(response.body) }

  describe "GET #index" do
    let(:updaters) { json.map { |j| j["attributes"]["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(json[1]["attributes"]["system-name"]).to be == "NGANJI" }
      it { expect(json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {system: " nganjI "} }
        it { expect(json[0]["attributes"]["system-name"]).to be == "NGANJI" }
        it { expect(json.size).to be == 1 }
      end

      context "on updater" do
        before { get :index, {updater: "  DOMMAARRAA"} }
        it { expect(json[0]["attributes"]["system-name"]).to be == "STUEMEAE AA-A D5464" }
        it { expect(json.size).to be == 1 }
      end

      context "on world" do
        before { get :index, {world: "a 5 "} }
        it { expect(json[0]["attributes"]["system-name"]).to be == "SHINRARTA DEZHRA" }
        it { expect(json.size).to be == 2 }
      end

      context "on updated_before" do
        before { get :index, {updated_before: Time.now - 3.days} }
        it { expect(updaters).to include "Finwen" }
        it { expect(updaters).to include "Marlon Blake" }
        it { expect(json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {updated_after: Time.now - 3.days} }
        it { expect(updaters).to include "Dommaarraa" }
        it { expect(json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:world) { json["attributes"] }

    before { get :show, {id: worlds[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(world["system-name"]).to be == "STUEMEAE AA-A D5464" }
    it { expect(world["updater"]).to be == "Dommaarraa" }
  end

  describe "POST #create" do
    let(:world_json) { json["attributes"] }
    let(:new_world_json) { { world:
                              { system: "Magrathea", 
                                updater: "Arthur Dent", 
                                world: "B 2", 
                                gravity: 1.3 } }
                           }
    let(:new_world) { world = new_world_json[:world]
                      world[:system_name] = world.delete(:system) 
                      world }

    context "adding a world" do
      before { post :create, new_world_json, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(world_json["system-name"]).to be == "Magrathea" }
      it { expect(World.last.system_name).to be == "Magrathea" }
    end

    context "allows one world per updater per world" do
      before { create :world, new_world }
      before { post :create, new_world_json, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["world"]).to include "has already been taken for this system" }
    end

    context "rejects blanks in key fields" do
      before { post :create, {world: {terrain_difficulty: 3}}, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["updater"]).to include "can't be blank" }
      it { expect(json_errors["system_name"]).to include "can't be blank" }
      it { expect(json_errors["world"]).to include "can't be blank" }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_world) { { world:
        { system: "MAGRATHEA", updater: "ARTHUR DENT", world: "b 2", gravity: 0.22 } }
      }

      before { create :world, new_world }
      before { post :create, clashing_world, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["world"]).to include "has already been taken for this system" }
    end

    context "unauthorized" do
      before { post :create, new_world_json }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updater) { "Eisen" }
    let(:updated_world) { { id: worlds[1].id,
                             world: { gravity: 0.43,
                                      updater: "Myshka"}} }
    context "updating a world" do
      before { put :update, updated_world, auth_tokens }
      let(:world) { World.find(worlds[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(world.system_name).to be == "NGANJI" }
      it { expect(world.gravity).to be 0.43}
      it { expect(world.updater).to be == "Myshka" }
    end
    
    context "as a normal user" do
      let(:user) { users[:marlon] }
      before { put :update, updated_world, auth_tokens }
      before { worlds[1].reload }
      
      it { expect(response).to have_http_status(204) }
      it { expect(worlds[1].updater).to be == "Marlon Blake" }
    end

    context "attempting to rename a system name" do
      let(:user) { users[:marlon] }
      before { updated_world[:world][:system_name] = "Basingstoke" }
      before { put :update, updated_world, auth_tokens }
      
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["system_name"]).to include "cannot be renamed this way" }
    end

    context "unauthenticated" do
      before { put :update, updated_world }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { worlds[0].id }
    context "as application user" do
      context "without child surveys" do
        before { delete :destroy, {id: id,
                                   user: "Marlon Blake"}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(World.where(id: id).any?).to be false }
      end
      
      context "with linked data" do
        let!(:world_survey) { create(:world_survey, world: worlds[0]) }
        before { delete :destroy, {id: id,
                                   user: "Marlon Blake"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
      
      context "deleting when not the creator" do
        before { delete :destroy, {id: id,
                                   user: "Kancro Vantas"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
      
      context "deleting with no user record" do
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "as a normal user" do
      context "deleting own record" do
        let(:user) { User.where(name: "Marlon Blake").first }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(World.where(id: id).any?).to be false }
      end
      
      context "deleting someone elses record" do
        let(:user) { create(:user, name: "Kancro Vantos") }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "as admin" do
      let(:user) { users[:admin] }
      context "disregard child links" do
        let!(:world_survey) { create(:world_survey, world: worlds[0]) }
        before { delete :destroy, {world_id: worlds[0].id,
                                   id: id}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(World.where(id: id).any?).to be false }
        it { expect(WorldSurvey.where(id: world_survey.id).any?).to be false }
      end
    end
    
    context "unauthenticated" do
      let(:id) { worlds[0].id }
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end

    context "unauthorized banned user" do
      let(:id) { worlds[0].id }
      let(:auth_tokens) { sign_in users[:banned]}
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end

  end
end
