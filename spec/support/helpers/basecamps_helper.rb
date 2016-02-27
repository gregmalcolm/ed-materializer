module BasecampsHelper
  def spawn_basecamps(world1: nil, world2:nil)
    world1 ||= create(:world, system: "BYEIA EUQ FB-O E6-3")
    world2 ||= create(:world)

    time = Time.now
    [
      create(:basecamp,
             world: world1,
             name: "FGE BC1",
             updater: "Nexolek",
             landing_zone_terrain: "Hilly / Mountainous",
             landing_zone_lat: -76.232, 
             landing_zone_lon: 23.23,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:basecamp,
             world: world1,
             name: "FGE BC2",
             updater: "Anthor",
             landing_zone_terrain: "Valley",
             landing_zone_lat: 23.232, 
             landing_zone_lon: -43.23,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:basecamp,
             world: world2,
             name: "Dark Fortress",
             updater: "Majkl578",
             landing_zone_terrain: nil,
             landing_zone_lat: 73.35,
             landing_zone_lon: 49.49,
             updated_at: time - 1.days,
             created_at: time - 1.days),
    ]
  end
end
