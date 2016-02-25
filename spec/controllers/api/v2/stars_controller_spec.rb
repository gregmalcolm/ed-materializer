require 'rails_helper'
require 'support/helpers/auth_helper.rb'
require 'support/helpers/stars_helper.rb'

describe Api::V2::StarsController, type: :controller do
  include AuthHelper
  include StarsHelper
  include Devise::TestHelpers

  let!(:stars) { spawn_stars }
  let!(:users) { spawn_users }
  let(:auth_tokens) { sign_in users[:edd]}
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
    let(:star) { json["star"] }

    before { get :show, {id: stars[2].id} }
    it { expect(response).to have_http_status(200) }
    it { expect(star["system"]).to be == "ALDERAAN" }
    it { expect(star["updater"]).to be == "robbyxp1" }
  end

  describe "POST #create" do
    let(:star) { json["star"] }
    let(:new_star) { { star:
      { system: "Magrathea", updater: "Ford Prefect", star: "", star_age: 50000.5 } }
    }

    context "adding a star" do
      before { post :create, new_star, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(star["system"]).to be == "Magrathea" }
      it { expect(Star.last.system).to be == "Magrathea" }
    end

    context "allows one record per star" do
      before { create :star, new_star[:star] }
      before { post :create, new_star, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["star"]).to include "has already been taken for this system" }
    end

    context "rejects blanks in key fields" do
      before { post :create, {star: {surface_temp: 44}}, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["updater"]).to include "can't be blank" }
      it { expect(json["system"]).to include "can't be blank" }
      it { expect(json["star"]).to_not include "can't be blank" }
    end

    context "adding a star updates every field" do
      let(:full_attributes) { attributes_for(:star, :full) }
      let(:new_star) { {star: full_attributes} }
      before { post :create, new_star, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(star.values).to_not include be_blank }
    end

    context "when checking for clashing systems, take into account casing" do
      let(:clashing_star) { { star:
        { system: "MAGRATHEA", updater: "fORD pREFECT", star: "", notes: "Again!" } }
      }

      before { create :star, new_star[:star] }
      before { post :create, clashing_star, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["star"]).to include "has already been taken for this system" }
    end

    context "unauthorized" do
      before { post :create, new_star }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updated_star) { { id: stars[1].id,
                             star: { solar_mass: 3.14 }} }
    context "updating a star" do
      before { put :update, updated_star, auth_tokens }
      let(:star) { Star.find(stars[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(star.system).to be == "Hoth" }
      it { expect(star.solar_mass).to be 3.14 }
    end

    context "unauthenticated" do
      before { put :update, updated_star }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    context "unauthenticated" do
      let(:id) { stars[0].id }
      before { delete :destroy, {id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized basic user" do
      let(:id) { stars[0].id }
      let(:auth_tokens) { sign_in users[:marlon]}
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "authorized power user" do
      let(:id) { stars[0].id }
      before { delete :destroy, {id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
      it { expect(Star.where(id: id).any?).to be false }
    end
  end
end
