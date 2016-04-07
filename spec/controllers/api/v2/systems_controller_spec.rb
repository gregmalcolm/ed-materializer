require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/systems_helper.rb'

describe Api::V2::SystemsController, type: :controller do
  include AuthHelper
  include SystemsHelper
  include Devise::TestHelpers
  
  let!(:systems) { spawn_systems }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:systems_json) { json["systems"] }
    let(:updaters) { systems_json.map { |j| j["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(systems_json[2]["system"]).to be == "CEECKIA ZQ-L C24-0" }
      it { expect(systems_json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {system: "NGANJI"} }
        it { expect(systems_json[0]["updater"]).to be == "Finwen" }
        it { expect(systems_json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:system) { json["system"] }

    before { get :show, {id: systems[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(system["poi_name"]).to be == "Beagle Point" }
  end

  describe "POST #create" do
    let(:system) { json["system"] }
    let(:new_system) { { system:
      { system: "Magrathea", updater: "Slartibartfast", tags: ["Home"]} }
    }

    context "adding a system" do
      before { post :create, new_system, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(system["system"]).to be == "Magrathea" }
      it { expect(System.last.system).to be == "Magrathea" }
      it { expect(System.last.updater).to be == "Slartibartfast" }
    end

    context "allows one record per system" do
      before { create :system, new_system[:system] }
      before { post :create, new_system, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["system"]).to include "has already been taken for this system" }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_system) { { system:
        { system: "MAGRATHEA", updater: "fORD pREFECT", notes: "Again!" } }
      }

      before { create :system, new_system[:system] }
      before { post :create, clashing_system, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["system"]).to include "has already been taken for this system" }
    end

    context "as a normal user" do
      let(:user) { users[:marlon] }
      
      context "has a fixed updater field of self" do
        before { post :create, new_system, auth_tokens }
        it { expect(System.last.updater).to be == "Marlon Blake" }
      end
    end

    context "unauthorized" do
      before { post :create, new_system }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updater) { "Eisen" }
    let(:updated_system) { { id: systems[1].id,
                               system: { x: 111.1, y: 222.2, z: -333.3,
                                         updater: updater}}}
    context "as a normal user" do
      let(:user) { users[:marlon] }
      before { put :update, updated_system, auth_tokens }
      before { systems[1].reload }
      
      it { expect(response).to have_http_status(204) }
      it { expect(systems[1].updater).to be == "Marlon Blake" }
    end

    context "unauthenticated" do
      before { put :update, updated_system }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
    
    context "as a banned user" do
      let(:user) { users[:banned] }
      before { put :update, updated_system, auth_tokens }
      
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { systems[0].id }
    
    context "as a normal user" do
      context "deleting own record" do
        let(:user) { create(:user, name: "Marlon Blake") }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(System.where(id: id).any?).to be false }
      end
      
      context "deleting someone elses record" do
        let(:user) { create(:user, name: "Dr. Kaii") }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
      
      context "when the is a world associated with the system" do
        let!(:world) { create(:world, system: "Shinrarta Dezhra") }
        before { delete :destroy, {id: id,
                                   user: "Marlon Blake"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end

    context "unauthenticated" do
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
    
    context "as an admin" do
      let(:user) { users[:admin] }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
    end
  end
end
