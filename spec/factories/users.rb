FactoryGirl.define do
  factory :user do
    provider "email"
    email "shepherd@example.com"
    name "CMDR Shepherd"
    password "normandy"
    confirmed_at Time.now

    trait :admin do
      role "admin"
      uid "admin@example.com"
      name "EDDiscovery"
      password "dangerous"
    end
  end
end
