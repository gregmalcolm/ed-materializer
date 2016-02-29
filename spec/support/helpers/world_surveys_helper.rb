module WorldSurveysHelper
  def spawn_world_surveys(world1: nil, world2: nil, world3: nil)
    world1 ||= create(:world, system: "BYEIA EUQ FB-O E6-3")
    world2 ||= create(:world, system: "BYEIA EUQ FB-O E6-4")
    world3 ||= create(:world)
    
    time = Time.now
    [
      create(:world_survey,
             world: world1,
             updater: "Marlon Blake",
             carbon: true,
             arsenic: true,
             germanium: true,
             molybdenum: true,
             niobium: true,
             polonium: true,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:world_survey,
             world: world2,
             updater: "Finwen",
             iron: false,
             nickel: true,
             phosphorus: true,
             sulphur: true,
             chromium: true,
             germanium: true,
             manganese: true,
             tin: true,
             antimony: true,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:world_survey,
             world: world3,
             updater: "Dommaarraa", # Thanks for the mats spreadsheet!
             carbon: false,
             iron: true,
             nickel: false,
             phosphorus: true,
             sulphur: true,
             manganese: true,
             selenium: true,
             molybdenum: true,
             niobium: true,
             updated_at: time - 1.days,
             created_at: time - 1.days),
    ]
  end
end
