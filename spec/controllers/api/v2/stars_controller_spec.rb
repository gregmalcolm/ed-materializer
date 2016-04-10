require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/stars_helper.rb'

describe Api::V2::StarsController, type: :controller do
  include AuthHelper
  include StarsHelper
  include Devise::TestHelpers

  let!(:stars) { spawn_stars }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:stars_json) { json["stars"] }
    let(:updaters) { stars_json.map { |j| j["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {} }
      it { expect(response).to have_http_status(200) }
      it { expect(stars_json[1]["system"]).to be == "Hoth" }
      it { expect(stars_json.size).to be >= 3 }
    end

    describe "filtering" do
      context "on system" do
        before { get :index, {system: " hoth "} }
        it { expect(stars_json[0]["system"]).to be == "Hoth" }
        it { expect(stars_json.size).to be == 1 }
      end

      context "on updater" do
        before { get :index, {updater: "  robbyxp1"} }
        it { expect(stars_json[0]["system"]).to be == "ALDERAAN" }
        it { expect(stars_json.size).to be == 1 }
      end

      context "on star" do
        before { get :index, {star: "b"} }
        it { expect(stars_json[0]["system"]).to be == "ALDERAAN" }
        it { expect(stars_json.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, {updated_before: Time.now - 3.days} }
        it { expect(updaters).to include "Cruento Mucrone" }
        it { expect(updaters).to include "Zed" }
        it { expect(stars_json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, {updated_after: Time.now - 3.days} }
        it { expect(updaters).to include "robbyxp1" }
        it { expect(stars_json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:star_json) { json["star"] }

    before { get :show, {id: stars[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(star_json["system"]).to be == "ALDERAAN" }
    it { expect(star_json["updater"]).to be == "robbyxp1" }
  end

  describe "POST #create" do
    let(:star_json) { json["star"] }
    let(:new_star_json) { { star:
                            { system: "Magrathea", 
                              updater: "Ford Prefect", 
                              star: "", 
                              star_age: 50000.5 } }
                        }
    let(:new_star) { star = new_star_json[:star]
                     star[:system_name] = star.delete(:system) 
                     star }

    context "adding a star" do
      before { post :create, new_star_json, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(star_json["system"]).to be == "Magrathea" }
      it { expect(Star.last.system_name).to be == "Magrathea" }
      it { expect(Star.last.updater).to be == "Ford Prefect" }
    end

    context "allows one record per star" do
      before { create :star, new_star }
      before { post :create, new_star_json, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["star"]).to include "has already been taken for this system" }
    end

    context "rejects blanks in key fields" do
      before { post :create, {star: {surface_temp: 44}}, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["updater"]).to include "can't be blank" }
      it { expect(json["system_name"]).to include "can't be blank" }
      it { expect(json["star"]).to_not include "can't be blank" }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_star) { { star:
        { system: "MAGRATHEA", 
          updater: "fORD pREFECT", 
          star: "", 
          notes: "Again!" } }
      }

      before { create :star, new_star }
      before { post :create, clashing_star, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["star"]).to include "has already been taken for this system" }
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
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updater) { "Eisen" }
    let(:updated_star) { { id: stars[1].id,
                               star: { solar_mass: 3.14,
                                       updater: updater}}}
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
      before { updated_star[:star][:system_name] = "David Braben" }
      before { put :update, updated_star, auth_tokens }
      
      it { expect(response).to have_http_status(422) }
      it { expect(json["system_name"]).to include "cannot be renamed this way" }
    end

    context "unauthenticated" do
      before { put :update, updated_star }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
    
    context "as a banned user" do
      let(:user) { users[:banned] }
      before { put :update, updated_star, auth_tokens }
      
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
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
        let(:user) { create(:user, name: "Cruento Mucrone") }
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
      it { expect(json["errors"]).to include "Authorized users only." }
    end
    
    context "as an admin" do
      let(:user) { users[:admin] }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
    end
  end
end
