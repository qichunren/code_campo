FactoryGirl.define do
  factory :user, :class => GUser do
    sequence(:name){|n| "name#{n}" }
    sequence(:email){|n| "email#{n}@codecampo.com" }
  end
end
