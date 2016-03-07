FactoryGirl.define do
  factory :user do
    provider "email"
    email "shepherd@example.com"
    name "CMDR Shepherd"
    password "normandy"
    confirmed_at Time.now

    trait :application do
      role "application"
      uid "application@example.com"
      name "EDDiscovery"
      password "dangerous"
    end
    
    trait :admin do
      role "admin"
      uid "admin@example.com"
      name "Boss"
      password "superadmin"
    end
  end
end
