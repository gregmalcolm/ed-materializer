require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/systems_helper.rb'

describe Api::V4::SystemsController, type: :controller do
  include AuthHelper
  include SystemsHelper
  include Devise::TestHelpers
  
  let!(:systems) { spawn_systems }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  before { set_json_api_headers }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)["data"]}
  let(:json_errors) { JSON.parse(response.body)["errors"] }
  let(:validation_errors) { json_errors.map { |e| e["detail"] } }

  describe "GET #index" do
    let(:updaters) { json.map { |j| j["attributes"]["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(json[2]["attributes"]["system"]).to be == "CEECKIA ZQ-L C24-0" }
      it { expect(json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {system: "NGANJI"} }
        it { expect(json[0]["attributes"]["updater"]).to be == "Finwen" }
        it { expect(json.size).to be == 1 }
      end

      context "search queries" do
        before { get :index, {q: "e"} }
        it { expect(json[0]["attributes"]["system"]).to be == "SHINRARTA DEZHRA" }
        it { expect(json.size).to be == 2 }
      end
    end
  end

  describe "GET #show" do
    let(:system) { json["attributes"] }

    before { get :show, {id: systems[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(system["poi-name"]).to be == "Beagle Point" }
  end

  describe "POST #create" do
    let(:system) { json["attributes"] }
    let(:new_system_json) { { data: { 
                                type: "systems",
                                attributes: {
                                  system: "Magrathea", 
                                  updater: "Slartibartfast", 
                                  tags: ["Home"] }}}
    }
    let(:new_system) { new_system_json[:data][:attributes]}

    context "adding a system" do
      before { post :create, new_system_json, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(system["system"]).to be == "Magrathea" }
      it { expect(System.last.system).to be == "Magrathea" }
      it { expect(System.last.updater).to be == "Slartibartfast" }
    end

    context "allows one record per system" do
      before { create :system, new_system }
      before { post :create, new_system_json, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(validation_errors).to include "System name has already been taken for this system" }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_system) { { data: { 
                                  type: "systems",
                                  attributes: {
                                    system: "MAGRATHEA", 
                                    updater: "fORD pREFECT", 
                                    notes: "Again!" }}}
      }

      before { create :system, new_system }
      before { post :create, clashing_system, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(validation_errors).to include "System name has already been taken for this system" }
    end

    context "as a normal user" do
      let(:user) { users[:marlon] }
      
      context "has a fixed updater field of self" do
        before { post :create, new_system_json, auth_tokens }
        it { expect(System.last.updater).to be == "Marlon Blake" }
      end
    end

    context "unauthorized" do
      before { post :create, new_system_json }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updater) { "Eisen" }
    let(:updated_system) { { id: systems[1].id,
                             data: { 
                               type: "systems",
                               id: systems[1].id,
                               attributes: {
                                 x: 111.1, 
                                 y: 222.2, 
                                 z: -333.3,
                                 updater: updater}}} }
    context "as a normal user" do
      let(:user) { users[:marlon] }
      before { patch :update, updated_system, auth_tokens }
      before { systems[1].reload }
      
      it { expect(response).to have_http_status(204) }
      it { expect(systems[1].updater).to be == "Marlon Blake" }
    end

    context "unauthenticated" do
      before { patch :update, updated_system }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors).to include "Authorized users only." }
    end
    
    context "as a banned user" do
      let(:user) { users[:banned] }
      before { patch :update, updated_system, auth_tokens }
      
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { systems[0].id }
    
    context "as a normal user" do
      context "deleting own record" do
        let(:user) { User.where(name: "Marlon Blake").first }
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
        let!(:world) { create(:world, system_name: "Shinrarta Dezhra") }
        before { delete :destroy, {id: id,
                                   user: "Marlon Blake"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end

    context "unauthenticated" do
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors).to include "Authorized users only." }
    end
    
    context "as an admin" do
      let(:user) { users[:admin] }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
    end
  end
end
