require 'rails_helper'

describe Basecamp do
  subject { create :basecamp }
  
  describe "Cascading deletes" do
    let!(:site_surveys) { create_list :site_survey, 3, basecamp_id: subject.id,
                                                        commander: "LordFedora"}
    before { subject.destroy }
    it { expect(SiteSurvey.by_commander("LordFedora").count).to be == 0 }
  end

  describe "#has_children?" do
    context "with no children" do
      let(:children) { subject.has_children? }
      it { expect( children ).to be false }
    end
    
    context "with children" do
      let!(:site_survey) { create(:site_survey, basecamp: subject) }
      let(:children) { subject.has_children? }
      it { expect( children ).to be true }
    end
  end
end
