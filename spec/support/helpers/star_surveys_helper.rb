module StarSurveysHelper
  def spawn_star_surveys
    time = Time.now
    [
      create(:star_survey,
             system: "Alderaan",
             commander: "Cruento Mucrone",
             star: "A",
             star_type: "F",
             subclass: "V",
             solar_mass: 2.2,
             solar_radius:  3.3,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:star_survey,
             system: "Hoth",
             commander: "Zed",
             star: "",
             star_type: "F",
             subclass: "VAB",
             solar_mass: 2.3,
             solar_radius:  2.3,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:star_survey,
             system: "ALDERAAN",
             commander: "robbyxp1",
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
