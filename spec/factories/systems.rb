FactoryGirl.define do
  factory :system do
    system "Iorant FR-C c26-0"
    updater "Chris Rosenkreutz"
    updaters ["Marlon Blake", "Chris Rosenkreutz", "Werdna"]

    trait :full do
      x -420.125
      y -23.28125
      z 65338.59375
      poi_name "The Treehouse"
      notes "Long way home!"
      image_url "http://i.imgur.com/lcASEtu.jpg"
      tags ["Has landables", "Long jump"]
    end
  end
end
