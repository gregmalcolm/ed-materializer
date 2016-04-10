require 'rails_helper'

describe System do
  subject! { create :system, updater: "Drownerfood", system: system_name }
  let(:system_name) { "Witcher World" }

  describe "changing the system name" do
    let!(:world1) { create :world, system_name: system_name, world: "A1" }
    let!(:world2) { create :world, system_name: system_name, world: "A2" }
    let!(:star)   { create :star,  system_name: system_name, star: "A" }

    before { subject.update(system: "Witchita") }
    it { world1.reload; expect(world1.system_name).to be == "Witchita" }
    it { world2.reload; expect(world2.system_name).to be == "Witchita" }
    it { star.reload;   expect(star.system_name).to be == "Witchita" }
  end
end
