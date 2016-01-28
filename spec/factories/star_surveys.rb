FactoryGirl.define do
  factory :star_survey do
    system "Betalgeuse"
    commander "Jameson"
    star "A"
    is_primary_star true

    trait :full do
       note "Unlikely"
    end
  end
end
