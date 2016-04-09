module WorldsHelper
  def spawn_worlds
    time = Time.now
    [
      create(:world,
             system_name: "SHINRARTA DEZHRA",
             updater: "Marlon Blake",
             world: "A 5",
             world_type: "High Metal Content",
             terraformable: false,
             gravity: 0.99,
             terrain_difficulty: 2,
             updated_at: time - 10.days,
             created_at: time - 10.days),
      create(:world,
             system_name: "NGANJI",
             updater: "Finwen",
             world: "B 3",
             world_type: "High Metal Content",
             terraformable: false,
             gravity: 1.47,
             terrain_difficulty: 3,
             updated_at: time - 5.days,
             created_at: time - 5.days),
      create(:world,
             system_name: "STUEMEAE AA-A D5464",
             updater: "Dommaarraa", 
             world: "A 5",
             world_type: "High Metal Content",
             terraformable: false,
             gravity: 0.99,
             terrain_difficulty: 2,
             updated_at: time - 1.days,
             created_at: time - 1.days),
    ]
  end
end
