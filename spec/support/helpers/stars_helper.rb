module StarsHelper
  def spawn_stars
    time = Time.now
    [
      create(:star,
             system_name: "Alderaan",
             updater: "Cruento Mucrone",
             star: "A",
             spectral_class: "F",
             spectral_subclass: "3",
             solar_mass: 2.2,
             solar_radius:  3.3,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:star,
             system_name: "Hoth",
             updater: "Zed",
             star: "",
             spectral_class: "F",
             spectral_subclass: "7",
             solar_mass: 2.3,
             solar_radius:  2.3,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:star,
             system_name: "ALDERAAN",
             updater: "robbyxp1",
             star: "B",
             spectral_class: "B",
             spectral_subclass: "5",
             solar_mass: 5.3,
             solar_radius:  4.3,
             updated_at: time - 1.days,
             created_at: time - 1.days),
    ]
  end
end
