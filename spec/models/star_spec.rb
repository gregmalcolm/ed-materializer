require 'rails_helper'

describe Star do
  subject { create :star, updater: "Katejina", system: "Yarnio" }

  describe "initialization" do
    it { expect(subject.creator).to be == "Katejina" }
  end
end
