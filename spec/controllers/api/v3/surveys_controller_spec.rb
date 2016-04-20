require 'rails_helper'
require 'support/helpers/auth_helper.rb'

describe Api::V3::SurveysController, type: :controller do
  include AuthHelper
  include WorldsHelper
  include BasecampsHelper
  include SurveysHelper
  include Devise::TestHelpers
  
  def combined_attrs(attributes, basecamp_id) 
    attributes.merge(basecamp_id: basecamp_id)
  end

  let!(:worlds) { spawn_worlds }
  let!(:basecamps) { spawn_basecamps(world1: worlds[0], world2: worlds[1]) }
  let!(:surveys) { spawn_surveys(basecamp1: basecamps[0], basecamp2: basecamps[2]) }
  let!(:users) { spawn_users }
  let(:user) { users[:edd] }
  let(:auth_tokens) { sign_in user}
  let(:json) { JSON.parse(response.body)}

  describe "GET #index" do
    let(:surveys_json) { json["surveys"] }
    let(:commanders) { surveys_json.map { |j| j["commander"] } }

    context "drinking from the firehouse" do
      before { get :index, {basecamp_id: basecamps[0].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(surveys_json[1]["commander"]).to be == "Mwerle" }
      it { expect(surveys_json.size).to be >= 2 }
    end

    describe "filtering" do
      context "on world_id" do
        before { get :index, {world_id: worlds[1].id} }
        it { expect(surveys_json[0]["commander"]).to be == "Michael Darkmoor" }
        it { expect(surveys_json.size).to be == 1 }
      end
      
      context "on basecamp_id" do
        before { get :index, {basecamp_id: basecamps[2].id} }
        it { expect(surveys_json[0]["commander"]).to be == "Michael Darkmoor" }
        it { expect(surveys_json.size).to be == 1 }
      end
      
      context "on commander" do
        before { get :index, {basecamp_id: basecamps[0].id, 
                              commander: "  Eoran "} }
        it { expect(surveys_json[0]["resource"]).to be == "Bronzite Chondrite" }
        it { expect(surveys_json.size).to be == 1 }
      end
      
      context "resource" do
        before { get :index, {basecamp_id: basecamps[2].id, 
                              resource: "AGGREGATED"} }
        it { expect(surveys_json[0]["commander"]).to be == "Michael Darkmoor" }
        it { expect(surveys_json.size).to be == 1 }
      end

      context "on updated_before" do
        before { get :index, updated_before: Time.now - 3.days}
        it { expect(commanders).to include "Eoran" }
        it { expect(commanders).to include "Mwerle" }
        it { expect(surveys_json.size).to be == 2 }
      end

      context "on updated_after" do
        before { get :index, updated_after: Time.now - 3.days}
        it { expect(commanders).to include "Michael Darkmoor" }
        it { expect(surveys_json.size).to be == 1 }
      end
    end
  end

  describe "GET #show" do
    let(:survey) { json["survey"] }
    context "nested" do
      before { get :show, {id: surveys[2].id,
                           basecamp_id: basecamps[1].id} }
      it { expect(response).to have_http_status(200) }
      it { expect(survey["commander"]).to be == "Michael Darkmoor" }
    end

    context "not nested" do
      before { get :show, {id: surveys[2].id } }
      it { expect(response).to have_http_status(200) }
      it { expect(survey["commander"]).to be == "Michael Darkmoor" }
    end
  end

  describe "POST #create" do
    let(:survey_json) { json["survey"] }
    let(:new_survey) { {
      resource: "Outcrop 1", 
      commander: "Marvin", 
      tin: 4,
      niobium: 5}
    }

    context "adding a survey" do
      before { get :create, { world_id: worlds[0].id, 
                              survey: new_survey }, auth_tokens }
      it { expect(response).to have_http_status(201) }
      it { expect(survey_json["resource"]).to be == "Outcrop 1" }
      it { expect(Survey.last.commander).to be == "Marvin" }
    end

    context "unauthorized" do
      before { post :create, { basecamp_id: basecamps[1].id, 
                               survey: new_survey } }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "PATCH/PUT #update" do
    let(:commander) { "Mwerle" }
    let(:updated_survey) { { basecamp_id: basecamps[0].id,
                                  id: surveys[1].id,
                                  survey: {mercury: 51,
                                                commander: commander} } }
    context "as an application user" do
      context "updating a survey" do
        before { put :update, updated_survey, auth_tokens }
        let(:survey) { Survey.find(surveys[1].id)}
        it { expect(response).to have_http_status(204) }
        it { expect(survey.commander).to be == "Mwerle" }
        it { expect(survey.mercury).to be 51 }
      end
      context "updating as a normal user" do
        context "changing someone elses record" do
          let(:commander) { "Coldglider" }
          before { put :update, updated_survey, auth_tokens }
          let(:survey) { Survey.find(surveys[1].id)}
          
          it { expect(response).to have_http_status(403) }
        end
        context "changing the error status" do
          let(:error_fields) { {error_flag: true,
                                error_description: "There is no tungsten here",
                                error_updater: "Allitnil" } }
          let(:updated_survey) { { id: surveys[2], survey: error_fields } }

          context "do not have to be the commander" do
            before { put :update, updated_survey, auth_tokens }
            it { expect(response).to have_http_status(204) }
            let(:survey) { Survey.find(surveys[2].id)}
            it { expect(survey.commander).to be == "Michael Darkmoor" }
            it { expect(survey.error_flag).to be true }
          end
          
          context "non commander cannot touch other fields" do
            before { error_fields["yttrium"] = true }
            before { put :update, updated_survey, auth_tokens }
            it { expect(response).to have_http_status(403) }
          end
        end
      end
    end
    
    context "as a normal user" do
      let(:user) { create(:user, name: "Mwerle") }
      
      context "changing own record" do
        before { put :update, updated_survey, auth_tokens }
        let(:survey) { Survey.find(surveys[1].id)}
        
        it { expect(response).to have_http_status(204) }
        it { expect(survey.commander).to be == "Mwerle" }
      end
      
      context "changing someone elses record" do
        let(:user) { users[:marlon] }
        before { put :update, updated_survey, auth_tokens }
        let(:survey) { Survey.find(surveys[1].id)}
        
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "as an admin" do
      let(:user) { users[:admin] }
      let(:commander) { "Coldglider" }
      
      context "changing someone elses record" do
        before { put :update, updated_survey, auth_tokens }
        let(:survey) { Survey.find(surveys[1].id)}
        
        it { expect(response).to have_http_status(204) }
        it { expect(survey.commander).to be == "Coldglider" }
        it { expect(survey.mercury).to be 51 }
      end
    end

    context "not nested" do
      let(:updated_survey) { { id: surveys[1].id,
                                    survey: { basecamp_id: basecamps[0].id, 
                                                   polonium: 5,
                                                   commander: "Mwerle" } } }
      before { put :update, updated_survey, auth_tokens }
      let(:survey) { Survey.find(surveys[1].id)}
      it { expect(response).to have_http_status(204) }
      it { expect(survey.polonium).to be 5 }
    end

    context "unauthenticated" do
      before { put :update, updated_survey }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end

  describe "DELETE #destroy" do
    let(:id) { surveys[0].id }
    context "as an application user" do
      context "deleting own record" do
        before { delete :destroy, {basecamp_id: basecamps[0].id,
                                   id: id,
                                   user: "Eoran"}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(Survey.where(id: id).any?).to be false }
      end
      
      context "deleting someone elses record" do
        before { delete :destroy, {basecamp_id: basecamps[0].id,
                                   id: id,
                                   user: "Coldglider"}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
      
      context "deleting with no user record" do
        before { delete :destroy, {basecamp_id: basecamps[0].id,
                                   id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end

    context "as a normal user" do
      context "deleting own record" do
        let(:user) { create(:user, name: "Eoran") }
        before { delete :destroy, {basecamp_id: basecamps[0].id,
                                   id: id}, auth_tokens }
        it { expect(response).to have_http_status(204) }
        it { expect(Survey.where(id: id).any?).to be false }
      end
      
      context "deleting someone elses record" do
        let(:user) { create(:user, name: "Coldglider") }
        before { delete :destroy, {basecamp_id: basecamps[0].id,
                                   id: id}, auth_tokens }
        it { expect(response).to have_http_status(403) }
      end
    end
    
    context "as an admin" do
      let(:user) { users[:admin] }
      before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(204) }
    end

    context "unauthenticated" do
      before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 id: id} }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end

    context "unauthorized banned user" do
      let(:auth_tokens) { sign_in users[:banned]}
      before { delete :destroy, {basecamp_id: basecamps[0].id,
                                 id: id}, auth_tokens }
      it { expect(response).to have_http_status(401) }
      it { expect(json["errors"]).to include "Authorized users only." }
    end
  end
end
