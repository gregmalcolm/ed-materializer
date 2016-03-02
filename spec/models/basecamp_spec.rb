require 'rails_helper'

describe Basecamp do
  subject { create :basecamp }
  describe "Cascading deletes" do
    let!(:site_surveys) { create_list :site_survey, 3, basecamp_id: subject.id,
                                                        commander: "LordFedora"}
    before { subject.destroy }
    it { expect(SiteSurvey.by_commander("LordFedora").count).to be == 0 }
  end
end
