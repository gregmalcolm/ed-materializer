FactoryGirl.define do
  factory :star do
    system "Betalgeuse"
    updater "Jameson"
    star "A"

    trait :full do
       spectral_class "A"
       spectral_subclass "4"
       solar_mass 23.3
       solar_radius 90.1
       surface_temp 42
       star_age 1000000000
       orbit_period 20.4
       arrival_point 323.3
       luminosity "really shiny"
       notes "I was drunk during this survey"
       image_url "http://i.imgur.com/lcASEtu.jpg"
    end
  end
end
