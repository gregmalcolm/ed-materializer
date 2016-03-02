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
end
