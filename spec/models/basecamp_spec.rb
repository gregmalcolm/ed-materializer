require 'rails_helper'

describe Basecamp do
  subject { create :basecamp }
  
  describe "Cascading deletes" do
    let!(:surveys) { create_list :survey, 3, basecamp_id: subject.id,
                                                        commander: "LordFedora"}
    before { subject.destroy }
    it { expect(Survey.by_commander("LordFedora").count).to be == 0 }
  end

  describe "#has_children?" do
    context "with no children" do
      let(:children) { subject.has_children? }
      it { expect( children ).to be false }
    end
    
    context "with children" do
      let!(:survey) { create(:survey, basecamp: subject) }
      let(:children) { subject.has_children? }
      it { expect( children ).to be true }
    end
  end
end
