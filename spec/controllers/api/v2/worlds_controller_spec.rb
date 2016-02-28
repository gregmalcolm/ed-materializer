require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/worlds_helper.rb'

describe Api::V2::WorldsController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include Devise::TestHelpers

  let!(:worlds) { spawn_worlds }
  let!(:users) { spawn_users }
  let(:auth_tokens) { sign_in users[:edd]}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:worlds_json) { json["worlds"] }
    let(:updaters) { worlds_json.map { |j| j["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(worlds_json[1]["system"]).to be == "NGANJI" }
      it { expect(worlds_json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {system: " nganjI "} }
        it { expect(worlds_json[0]["system"]).to be == "NGANJI" }
        it { expect(worlds_json.size).to be == 1 }
      end

      context "on updater" do
        before { get :index, {updater: "  DOMMAARRAA"} }
        it { expect(worlds_json[0]["system"]).to be == "STUEMEAE AA-A D5464" }
        it { expect(worlds_json.size).to be == 1 }
      end

      context "on world" do
        before { get :index, {world: "a 5 "} }
        it { expect(worlds_json[0]["system"]).to be == "SHINRARTA DEZHRA" }
        it { expect(worlds_json.size).to be == 2 }
      end

      context "on updated_before" do
        before { get :index, {updated_before: Time.now - 3.days} }
        it { expect(updaters).to include "Finwen" }
        it { expect(updaters).to include "Marlon Blake" }
        it { expect(worlds_json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {updated_after: Time.now - 3.days} }
        it { expect(updaters).to include "Dommaarraa" }
        it { expect(worlds_json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:world) { json["world"] }

    before { get :show, {id: worlds[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(world["system"]).to be == "STUEMEAE AA-A D5464" }
    it { expect(world["updater"]).to be == "Dommaarraa" }
  end

  describe "POST #create" do
    let(:world) { json["world"] }
    let(:new_world) { { world:
      { system: "Magrathea", updater: "Arthur Dent", world: "B 2", gravity: 1.3 } }
    }

    context "adding a world" do
      before { post :create, new_world, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(world["system"]).to be == "Magrathea" }
      it { expect(World.last.system).to be == "Magrathea" }
    end

    context "allows one world per updater per world" do
      before { create :world, new_world[:world] }
      before { post :create, new_world, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["world"]).to include "has already been taken for this system" }
    end

    context "rejects blanks in key fields" do
      before { post :create, {world: {terrain_difficulty: 3}}, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["updater"]).to include "can't be blank" }
      it { expect(json["system"]).to include "can't be blank" }
      it { expect(json["world"]).to include "can't be blank" }
    end

    context "adding a world updates every field" do
      let(:full_attributes) { attributes_for(:world, :full) }
      let(:new_world) { {world: full_attributes} }
      before { post :create, new_world, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(world.values).to_not include be_blank }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_world) { { world:
        { system: "MAGRATHEA", updater: "ARTHUR DENT", world: "b 2", gravity: 0.22 } }
      }

      before { create :world, new_world[:world] }
      before { post :create, clashing_world, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["world"]).to include "has already been taken for this system" }
    end

    context "unauthorized" do
      before { post :create, new_world }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_world) { { id: worlds[1].id,
                             world: { gravity: 0.43 }} }
    context "updating a world" do
      before { put :update, updated_world, auth_tokens }
      let(:world) { World.find(worlds[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(world.system).to be == "NGANJI" }
      it { expect(world.gravity).to be 0.43}
    end

    context "unauthenticated" do
      before { put :update, updated_world }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    context "unauthenticated" do
      let(:id) { worlds[0].id }
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized basic user" do
      let(:id) { worlds[0].id }
      let(:auth_tokens) { sign_in users[:marlon]}
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "authorized power user" do
      let(:id) { worlds[0].id }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
      it { expect(World.where(id: id).any?).to be false }
    end
  end
end