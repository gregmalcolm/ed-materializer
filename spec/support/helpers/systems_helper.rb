module SystemsHelper
  def spawn_systems
    time = Time.now
    [
      create(:system,
             system: "SHINRARTA DEZHRA",
             updater: "Marlon Blake",
             x: 56.00,
             y: 17.00,
             z: 27.00,
             tags: ["Founders World"],
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:system,
             system: "NGANJI",
             updater: "Finwen",
             x: -25.00,
             y: 36.00,
             z: 130.00,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:system,
             system: "CEECKIA ZQ-L C24-0",
             updater: "Kamzel",
             x: -1111.56,
             y: -134.22,
             z: 65269.75,
             poi_name: "Beagle Point",
             tags: ["WP23: Beagle Point"],
             updated_at: time - 1.days,
             created_at: time - 1.days)
    ]
  end
end
