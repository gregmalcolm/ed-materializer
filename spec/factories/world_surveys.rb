FactoryGirl.define do
  factory :world_survey do
    system "Betalgeuse"
    commander "Jameson"
    world "A 1"

    trait :full do
       world_type "Rocky Body"
       terraformable "Terraformable"
       gravity 2.0
       terrain_difficulty 3
       arrival_point 12.4
       atmosphere_type 4
       vulcanism_type "lavaery"
       radius 3.4
       notes "Improbable"
       reserve "Reservey thing"
       mass 1.1
       surface_temp 32
       surface_pressure 4
       orbit_period 1.1
       rotation_period 2.2
       semi_major_axis 1.4
       rock_pct 33
       metal_pct 33
       ice_pct 34
       carbon true
       iron true
       nickel true
       phosphorus true
       sulphur true
       arsenic true
       chromium true
       germanium true
       manganese true
       selenium true
       vanadium true
       zinc true
       zirconium true
       cadmium true
       mercury true
       molybdenum true
       niobium true
       tin true
       tungsten true
       antimony true
       polonium true
       ruthenium true
       technetium true
       tellurium true
       yttrium true
    end
  end
end
