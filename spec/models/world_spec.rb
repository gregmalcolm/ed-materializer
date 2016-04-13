require 'rails_helper'

describe World do
  subject { create :world }
  describe "cascading deletes" do
    let!(:world_survey) { create :world_survey, world: subject, 
                                                updater: "Akira Masakari"}
    let!(:basecamp) { create :basecamp, world: subject, 
                                        name: "Camp Rock Rat",
                                        updater: "Baroness Galaxy"}
    let!(:surveys) { create_list :survey, 2, basecamp: basecamp,
                                                       commander: "Coldglider"}
    before { subject.destroy }
    it { expect(Basecamp.by_updater("Baroness Galaxy").count).to be == 0 }
    it { expect(Survey.by_commander("Coldglider").count).to be == 0 }
    it { expect(WorldSurvey.by_updater("Akira Masakari").count).to be == 0 }
  end

  describe "updating the parent system" do
    context "when the system not exist" do
      subject! { create :world, system_name: "Cybertron" }
      let(:system) { System.where(system: "Cybertron").first }
      it { expect(system).to be_present }
      it { expect(system.updater).to be == "Jameson"  }
      it { expect(subject.system).to be == system  }
    end

    context "when a compatible system exists" do
      before { create :system, system: "CYBERTRON", updater: "Wishblend" }
      subject! { create :world, system_name: "Cybertron" }
      let(:system) { System.where(system: "Cybertron").first }
      it { expect(system.system).to be == "Cybertron" }
      it { expect(system.updater).to be == "Jameson"  }
      it { expect(subject.system).to be == system  }
    end
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
