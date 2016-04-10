require 'rails_helper'

describe WorldSurvey do
  let!(:system) { create :system, system: "Steve" }
  let(:world) { create :world, system_name: "Steve", world: "1" }
  subject { create :world_survey, updater: "OlFart", world: world }

  describe "creates a link to the system" do
    it { expect(subject.system_id).to be == system.id }
  end
end
