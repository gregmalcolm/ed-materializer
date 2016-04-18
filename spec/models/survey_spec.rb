require 'rails_helper'

describe Survey do
  subject { create :survey, commander: "Maia Posidana", 
                            world: world, 
                            basecamp: basecamp }
 
  let!(:system) { create :system, system: "Potataho" }
  let(:world) { create :world, system_name: "Potataho", world: "Spudworld" }
  let(:basecamp) { create :basecamp, world: world }

  describe "creates a link to the system" do
    it { expect(subject.system_id).to be == system.id }
  end

  describe "updating world_surveys during updates" do
    let!(:survey1) { create :survey, world: world, 
                                     commander: "Mindwipe",
                                     niobium: 1,
                                     germanium: 1,
                                     arsenic: 2 }
    let!(:survey2) { create :survey, world: world,
                                     commander: "Dobbo",
                                     ruthenium: 1,
                                     germanium: 1,
                                     mercury: 1 }
    let!(:survey3) { create :survey, world: world,
                                     commander: "Leiawen",
                                     niobium: 4,
                                     zinc: 23,
                                     arsenic: 9 }

    context "for 3 surveys" do
      let(:world_survey) { WorldSurvey.where(world_id: world.id).first }
      it { expect(world_survey.niobium).to be true }
      it { expect(world_survey.germanium).to be true }
      it { expect(world_survey.mercury).to be true }
      it { expect(world_survey.zinc).to be true }
      it { expect(world_survey.yttrium).to be false }
      it { expect(world_survey.updaters).to be == %w[Mindwipe Dobbo Leiawen] }
    end

    context "updating a survey" do
      before { survey2.update({ruthenium: false, polonium: 4, germanium: 0}) }
      let(:world_survey) { WorldSurvey.where(world_id: world.id).first }
      it { expect(world_survey.polonium).to be true }
      it { expect(world_survey.ruthenium).to be false }
      it { expect(world_survey.germanium).to be true }
    end
    
    context "destroying a survey" do
      before { survey2.destroy }
      let(:world_survey) { WorldSurvey.where(world_id: world.id).first }
      it { expect(world_survey.mercury).to be false }
      it { expect(world_survey.germanium).to be true }
    end
    
    context "destroying all surveys" do
      before { Survey.where(world_id: world.id).destroy_all }
      let(:world_survey) { WorldSurvey.where(world_id: world.id).first }
      it { expect(world_survey).to be nil }
    end
    
    context "Ignores surveys flagged with errors" do
      before { survey3.update(error_flag: true, 
                              error_description: "Wrong, do it again!",
                              error_updater: "Nexolek") }
      let(:world_survey) { WorldSurvey.where(world_id: world.id).first }
      it { expect(world_survey.zinc).to be false }
      it { expect(world_survey.germanium).to be true }
    end
  end
  describe "updating world_surveys for a single survey" do
    let!(:survey) { create :survey, world: world, 
                                    commander: "iDragox",
                                    niobium: 1,
                                    germanium: 1,
                                    arsenic: 2 }

    context "All surveys are bad" do
      before { survey.update(error_flag: true, 
                             error_description: "Nope!",
                             error_updater: "Greytest") }
      let(:world_survey) { WorldSurvey.where(world_id: world.id).first }
      it { expect(world_survey).to be nil }
    end
  end
  describe "error fields" do
    context "flagging an error" do
      before { subject.update(error_flag: true)}
      it { expect(subject.errors[:error_description]).to include "not updated" }
      it { expect(subject.errors[:error_updater]).to include "not updated" }
    end
    
    context "unflagging an error" do
      before { subject.update(error_flag: true, 
                              error_description: "That's not right", 
                              error_updater: "Shellstrom")}
      before { subject.update(error_flag: false)}
      it { expect(subject.errors[:error_description]).to_not include "not updated" }
      it { expect(subject.errors[:error_updater]).to include "not updated" }
    end
  end
end
