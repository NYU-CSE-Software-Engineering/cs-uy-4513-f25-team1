FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    description { Faker::Lorem.paragraph }
    key { Faker::Alphanumeric.alpha(number: 3).upcase }

    trait :with_tasks do
      after(:create) do |project|
        create_list(:task, 3, project: project, user: project.users.first || create(:user))
      end
    end

    trait :invalid do
      name { nil }
    end
  end
end
