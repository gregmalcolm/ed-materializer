module SiteSurveysHelper
  def spawn_site_surveys(basecamp1: nil, basecamp2:nil)
    unless basecamp1
      world1 = create(:world, system: "BYEIA EUQ FB-O E6-3")
      basecamp1 = create(:basecamp1, world: world1, name: "FGE BC1")
    end
    unless basecamp2
      world2 = create(:world)
      basecamp2 = create(:basecamp2, world: world2, name: "DarkFortress")
    end

    time = Time.now
    [
      create(:site_survey,
             basecamp: basecamp1,
             commander: "Eoran",
             resource: "Bronzite Chondrite",
             carbon: 32,
             manganese: 23,
             polonium: 4,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:site_survey,
             basecamp: basecamp1,
             commander: "Mwerle",
             carbon: 2,
             nickel: 33,
             selenium: 42,
             zinc: 23,
             polonium: 2,
             resource: "Metallic Meteorite",
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:site_survey,
             basecamp: basecamp2,
             commander: "Michael Darkmoor",
             resource: nil,
             iron: 23,
             sulphur: 2,
             niobium: 4,
             tungsten: 7,
             ruthenium: 4,
             updated_at: time - 1.days,
             created_at: time - 1.days)
    ]
  end
end
