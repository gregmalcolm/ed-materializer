FactoryGirl.define do
  factory :star_survey do
    system "Betalgeuse"
    commander "Jameson"
    star "A"

    trait :full do
       note "Unlikely"
    end
  end
end
