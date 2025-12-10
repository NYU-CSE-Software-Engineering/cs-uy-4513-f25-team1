FactoryBot.define do
  factory :collaborator do
    association :user
    association :project
    role { :manager }

    trait :manager do
      role { :manager }
    end

    trait :developer do
      role { :developer }
    end

    trait :invited do
      role { :invited }
    end
  end
end
