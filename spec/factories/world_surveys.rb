FactoryGirl.define do
  factory :world_survey do
    world
    updater "Jameson"
    carbon true
    vanadium true
    ruthenium true

    trait :full do
       iron true
       nickel true
       phosphorus true
       sulphur true
       arsenic true
       chromium true
       germanium true
       manganese true
       selenium true
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
       technetium true
       tellurium true
       yttrium true
    end
  end
end
