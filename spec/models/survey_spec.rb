require 'rails_helper'

describe Survey do
  subject { create :survey, commander: "Maia Posidana", basecamp: basecamp }
 
  let!(:system) { create :system, system: "Potataho" }
  let(:world) { create :world, system_name: "Potataho", world: "Spudworld" }
  let(:basecamp) { create :basecamp, world: world }

  describe "creates a link to the system" do
    it { expect(subject.system_id).to be == system.id }
  end
end
