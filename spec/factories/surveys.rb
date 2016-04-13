FactoryGirl.define do
  factory :survey do
    basecamp
    world { basecamp.world }
    commander "Jameson"
    resource "Outcrop 2"

    trait :full do
      notes "It's all full of rocks"
      image_url "http://i.imgur.com/lcASEtu.jpg"
      iron 4
      nickel 9
      phosphorus 84
      sulphur 42
      arsenic 0
      chromium 99
      germanium 0
      manganese 0
      selenium 5
      vanadium 0
      zinc 12
      zirconium 0
      cadmium 0
      mercury 0
      molybdenum 0
      niobium 0
      tin 0
      tungsten 0
      antimony 0
      polonium 0
      ruthenium 0
      technetium 0
      tellurium 0
      yttrium 4
    end
  end
end
