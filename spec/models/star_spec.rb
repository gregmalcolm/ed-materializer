require 'rails_helper'

describe Star do
  subject { create :star, updater: "Katejina", system: "Yarnio" }

  describe "creator and updaters" do
    context "after initialization" do
      it { expect(subject.creator).to be == "Katejina" }
      it { expect(subject.updater).to be == "Katejina" }
      it { expect(subject.updaters).to be == ["Katejina"] }
    end

    context "after updates from someone else" do
      before { subject.update(spectral_subclass: 3, updater: "Erimus") }
      it { expect(subject.creator).to be == "Katejina" }
      it { expect(subject.updater).to be == "Erimus" }
      it { expect(subject.updaters).to be == ["Katejina", "Erimus"] }
    end
    
    context "after multiple updates with the first updater repeating" do
      before { subject.update(spectral_subclass: "3", updater: "Erimus") }
      before { subject.update(spectral_class: "K", updater: "Katejina") }
      it { expect(subject.creator).to be == "Katejina" }
      it { expect(subject.updater).to be == "Katejina" }
      it { expect(subject.updaters).to be == ["Katejina", "Erimus"] }
    end
  end
end
