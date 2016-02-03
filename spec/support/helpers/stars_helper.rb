module StarsHelper
  def spawn_stars
    time = Time.now
    [
      create(:star,
             system: "Alderaan",
             updater: "Cruento Mucrone",
             star: "A",
             star_type: "F",
             subclass: "V",
             solar_mass: 2.2,
             solar_radius:  3.3,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:star,
             system: "Hoth",
             updater: "Zed",
             star: "",
             star_type: "F",
             subclass: "VAB",
             solar_mass: 2.3,
             solar_radius:  2.3,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:star,
             system: "ALDERAAN",
             updater: "robbyxp1",
             star: "B",
             star_type: "B",
             subclass: "V",
             solar_mass: 5.3,
             solar_radius:  4.3,
             updated_at: time - 1.days,
             created_at: time - 1.days),
    ]
  end
end
