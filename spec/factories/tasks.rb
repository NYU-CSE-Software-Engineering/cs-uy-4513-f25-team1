FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    status { "To Do" }
    association :project
    association :user

    trait :todo do
      status { "To Do" }
    end

    trait :in_progress do
      status { "In Progress" }
    end

    trait :done do
      status { "Done" }
    end

    trait :invalid do
      title { nil }
    end
  end
end
