require 'rails_helper'
require 'support/helpers/auth_helper.rb'

describe Api::V2::WorldSurveysController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include WorldSurveysHelper
  include Devise::TestHelpers
  
  def combined_attrs(attributes, world_id) 
    attributes.merge(world_id: world_id)
  end

  let!(:worlds) { spawn_worlds }
  let!(:world_surveys) { spawn_world_surveys(world1: worlds[0], world2: worlds[1], world3: worlds[2]) }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:world_surveys_json) { json["world_surveys"] }
    let(:updaters) { world_surveys_json.map { |j| j["updater"] } }

    context "drinking from the firehouse" do
      before { get :index, {world_id: worlds[0].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(world_surveys_json[0]["carbon"]).to be true }
      it { expect(world_surveys_json.size).to be == 1 }
    end

    describe "filtering" do
      context "on world_id" do
        before { get :index, {world_id: worlds[1].id} }
        it { expect(world_surveys_json[0]["updater"]).to be == "Finwen" }
        it { expect(world_surveys_json.size).to be == 1 }
      end
      
      context "on updater" do
        before { get :index, {world_id: worlds[2].id, 
                              updater: "  DommAARRAA "} }
        it { expect(world_surveys_json[0]["updater"]).to be == "Dommaarraa" }
        it { expect(world_surveys_json.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, {updated_before: Time.now - 8.days} }
        it { expect(updaters).to include "Marlon Blake" }
        it { expect(world_surveys_json.size).to be == 1 }
      end

      context "on updated_after" do
        before { get :index, {updated_after: Time.now - 8.days} }
        it { expect(updaters).to include "Finwen" }
        it { expect(updaters).to include "Dommaarraa" }
        it { expect(world_surveys_json.size).to be == 2 }
      end
    end
  end

  describe "GET #show" do
    let(:world_survey) { json["world_survey"] }

    context "nested" do
      before { get :show, {id: world_surveys[2].id, 
                           world_id: worlds[1].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(world_survey["iron"]).to be true }
    end
    
    context "not nested" do
      before { get :show, {id: world_surveys[2].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(world_survey["iron"]).to be true }
    end
  end

  describe "POST #create" do
    let(:world_survey_json) { json["world_survey"] }
    let(:new_world_survey) { {
      updater: "Arthur Dent", 
      sulphur: false, 
      yttrium: true}
    }
    let(:new_world) { create :world }

    context "adding a world_survey" do
      before { get :create, { world_id: new_world.id, 
                              world_survey: new_world_survey }, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(world_survey_json["updater"]).to be == "Arthur Dent" }
      it { expect(WorldSurvey.last.updater).to be == "Arthur Dent" }
    end

    context "allows one record per world_survey" do
      let!(:existing_world_survey) { 
        create :world_survey, combined_attrs(new_world_survey, new_world.id) 
      }
      before { get :create, { world_id: new_world.id, 
                              world_survey: new_world_survey }, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["world_survey"][0]).to match(/has already been taken/) }
    end
    
    context "expects a world id" do
      before { expect { get :create, { world_survey: new_world_survey }, auth_tokens
                      }.to raise_error(RoutingError)
             }
    end

    context "rejects blanks in key fields" do
      before { get :create, { world_id: new_world.id, 
                              world_survey: { mercury: true} }, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["updater"]).to include "can't be blank" }
    end

    context "when checking for clashing names, take into account casing" do
      let(:clashing_world_survey) {
        { updater: "Arthur", tin: true }
      }

      let!(:existing_world_survey) { create :world_survey, combined_attrs(new_world_survey, new_world.id) }
      before { post :create, { world_id: new_world.id, 
                               world_survey: clashing_world_survey }, auth_tokens }
      it { expect(response).to have_http_status(422) }
      it { expect(json["world_survey"][0]).to match(/has already been taken/) }
    end

    context "unauthorized" do
      before { post :create, { world_id: new_world.id, 
                               world_survey: new_world_survey } }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:updater) { "Davros" }
    let(:updated_world_survey) { { world_id: worlds[1].id,
                                   id: world_surveys[1].id,
                                   world_survey: {updater: updater} } }
    context "updating a world_survey" do
      before { put :update, updated_world_survey, auth_tokens }
      let(:world_survey) { WorldSurvey.find(world_surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(world_survey.updater).to be == "Davros" }
      it { expect(world_survey.carbon).to be true }
    end

    context "as a normal user" do
      let(:user) { users[:marlon] }
      before { put :update, updated_world_survey, auth_tokens }
      before { world_surveys[1].reload }
      
      it { expect(response).to have_http_status(204) }
      it { expect(world_surveys[1].updater).to be == "Marlon Blake" }
    end
    
    context "not nested" do
      let(:updated_world_survey) { { id: world_surveys[1].id,
                                     world_survey: {world_id: worlds[1].id,
                                                    updater: "Davros" } } }
      before { put :update, updated_world_survey, auth_tokens }
      let(:world_survey) { WorldSurvey.find(world_surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(world_survey.updater).to be == "Davros" }
      it { expect(world_survey.carbon).to be true }
    end
    
    context "unauthenticated" do
      before { put :update, updated_world_survey }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { world_surveys[0].id }
    context "as an application user" do
      context "deleting as creator" do
        before { delete :destroy, {id: id,
                                   user: "Marlon Blake"}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(WorldSurvey.where(id: id).any?).to be false }
      end
      
      context "deleting when not the creator" do
        before { delete :destroy, {id: id,
                                   user: "John Rutherford"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
      
      context "deleting with no user record" do
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "as a normal user" do
      context "deleting own record" do
        let(:user) { create(:user, name: "Marlon Blake") }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(WorldSurvey.where(id: id).any?).to be false }
      end
      
      context "deleting someone elses record" do
        let(:user) { create(:user, name: "John Rutherford") }
        before { delete :destroy, {id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "unauthenticated" do
      before { delete :destroy, {world_id: worlds[0].id,
                                 id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized banned user" do
      let(:auth_tokens) { sign_in users[:banned]}
      before { delete :destroy, {world_id: worlds[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end
end
