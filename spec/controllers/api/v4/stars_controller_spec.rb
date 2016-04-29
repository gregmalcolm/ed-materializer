require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/stars_helper.rb'

describe Api::V4::StarsController, type: :controller do
  include AuthHelper
  include StarsHelper
  include Devise::TestHelpers

  let!(:stars) { spawn_stars }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  before { set_json_api_headers }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)["data"]}
  let(:json_errors) { JSON.parse(response.body) }

  describe "GET #index" do
    let(:updaters) { json.map { |j| j["attributes"]["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(json[1]["attributes"]["system-name"]).to be == "Hoth" }
      it { expect(json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system-name" do
        before { get :index, {system: " hoth "} }
        it { expect(json[0]["attributes"]["system-name"]).to be == "Hoth" }
        it { expect(json.size).to be == 1 }
      end

      context "on updater" do
        before { get :index, {updater: "  robbyxp1"} }
        it { expect(json[0]["attributes"]["system-name"]).to be == "ALDERAAN" }
        it { expect(json.size).to be == 1 }
      end

      context "on star" do
        before { get :index, {star: "b"} }
        it { expect(json[0]["attributes"]["system-name"]).to be == "ALDERAAN" }
        it { expect(json.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, {updated_before: Time.now - 3.days} }
        it { expect(updaters).to include "Cruento Mucrone" }
        it { expect(updaters).to include "Zed" }
        it { expect(json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {updated_after: Time.now - 3.days} }
        it { expect(updaters).to include "robbyxp1" }
        it { expect(json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:star_json) { json["attributes"] }

    before { get :show, {id: stars[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(star_json["system-name"]).to be == "ALDERAAN" }
    it { expect(star_json["updater"]).to be == "robbyxp1" }
  end

  describe "POST #create" do
    let(:star_json) { json["attributes"] }
    let(:new_star_json) { { data: {
                               type: "stars",
                               attributes:{ 
                                 system_name: "Magrathea", 
                                 updater: "Ford Prefect", 
                                 star: "", 
                                 star_age: 50000.5 },
                               relationships: {
                                 system: { id: nil }}
                          }}
                        }
    let(:new_star) { new_star_json[:data][:attributes] }

    context "adding a star" do
      before { post :create, new_star_json, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(star_json["system-name"]).to be == "Magrathea" }
      it { expect(Star.last.system_name).to be == "Magrathea" }
      it { expect(Star.last.updater).to be == "Ford Prefect" }
    end

    context "allows one record per star" do
      before { create :star, new_star }
      before { post :create, new_star_json, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["star"]).to include "has already been taken for this system" }
    end

    context "rejects blanks in key fields" do
      let(:new_star_json) { { data: {
                                type: "stars",
                                attributes: {surface_temp: 44},
                              relationships: {
                                system: { id: nil }}
                             }}
                           }
      before { post :create, new_star_json, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["updater"]).to include "can't be blank" }
      it { expect(json_errors["system_name"]).to include "can't be blank" }
      it { expect(json_errors["star"]).to_not include "can't be blank" }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_star) { { data: {
                                type: "stars",
                                attributes: { 
                                  system: "MAGRATHEA", 
                                  updater: "fORD pREFECT", 
                                  star: "", 
                                  notes: "Again!"},
                                relationships: {
                                  system: { id: nil }}
                                }}
      }

      before { create :star, new_star }
      before { post :create, clashing_star, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["star"]).to include "has already been taken for this system" }
    end

    context "as a normal user" do
      let(:user) { users[:marlon] }
      
      context "has a fixed updater field of self" do
        before { post :create, new_star_json, auth_tokens }
        it { expect(Star.last.updater).to be == "Marlon Blake" }
      end
    end

    context "unauthorized" do
      before { post :create, new_star_json }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updater) { "Eisen" }
    let(:updated_star) { { id: stars[1].id,
                           data: {
                             type: "stars",
                              attributes: { 
                                solar_mass: 3.14,
                                updater: updater},
                            relationships: {
                              system: { id: nil }}
                            }}
                        }
    context "as an application user" do
      context "updating a star" do
        before { put :update, updated_star, auth_tokens }
        let(:star) { Star.find(stars[1].id)}
        it { expect(response).to have_http_status(204) }
        it { expect(star.system_name).to be == "Hoth" }
        it { expect(star.solar_mass).to be == 3.14 }
        it { expect(star.updater).to be == "Eisen" }
      end
    end

    context "as a normal user" do
      let(:user) { users[:marlon] }
      before { put :update, updated_star, auth_tokens }
      before { stars[1].reload }
      
      it { expect(response).to have_http_status(204) }
      it { expect(stars[1].updater).to be == "Marlon Blake" }
    end
    
    context "attempting to rename a system name" do
      let(:user) { users[:marlon] }
      before { updated_star[:data][:attributes][:system_name] = "David Braben" }
      before { put :update, updated_star, auth_tokens }
      
      it { expect(response).to have_http_status(422) }
      it { expect(json_errors["system_name"]).to include "cannot be renamed this way" }
    end

    context "unauthenticated" do
      before { put :update, updated_star }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end
    
    context "as a banned user" do
      let(:user) { users[:banned] }
      before { put :update, updated_star, auth_tokens }
      
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { stars[0].id }
    context "as an application user" do
      context "deleting as creator" do
        before { delete :destroy, {id: id,
                                   user: "Cruento Mucrone"}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(Star.where(id: id).any?).to be false }
      end
      
      context "deleting when not the creator" do
        before { delete :destroy, {id: id,
                                   user: "Dr. Kaii"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
      
      context "deleting with no user record" do
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "as a normal user" do
      context "deleting own record" do
        let(:user) { User.where(name: "Cruento Mucrone").first }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(Star.where(id: id).any?).to be false }
      end
      
      context "deleting someone elses record" do
        let(:user) { create(:user, name: "Dr. Kaii") }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end

    context "unauthenticated" do
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json_errors["errors"]).to include "Authorized users only." }
    end
    
    context "as an admin" do
      let(:user) { users[:admin] }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
    end
  end
end
