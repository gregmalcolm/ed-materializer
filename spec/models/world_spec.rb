require 'rails_helper'

describe World do
  subject { create :world }
  describe "Cascading deletes" do
    let!(:world_survey) { create :world_survey, world: subject, 
                                                updater: "Akira Masakari"}
    let!(:basecamp) { create :basecamp, world: subject, 
                                        name: "Camp Rock Rat",
                                        updater: "Baroness Galaxy"}
    let!(:site_surveys) { create_list :site_survey, 2, basecamp: basecamp,
                                                       commander: "Coldglider"}
    before { subject.destroy }
    it { expect(Basecamp.by_updater("Baroness Galaxy").count).to be == 0 }
    it { expect(SiteSurvey.by_commander("Coldglider").count).to be == 0 }
    it { expect(WorldSurvey.by_updater("Akira Masakari").count).to be == 0 }
  end
  
  describe "#has_children?" do
    context "with no children" do
      let(:children) { subject.has_children? }
      it { expect( children ).to be false }
    end
    
    context "with a world_survey" do
      let!(:world_survey) { create(:world_survey, world: subject) }
      let(:children) { subject.has_children? }
      it { expect( children ).to be true }
    end
    
    context "with a basecamp" do
      let!(:world_survey) { create(:basecamp, world: subject) }
      let(:children) { subject.has_children? }
      it { expect( children ).to be true }
    end
  end
end
