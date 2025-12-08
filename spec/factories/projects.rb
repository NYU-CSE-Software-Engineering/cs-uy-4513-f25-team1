FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    description { Faker::Lorem.paragraph }
    wip_limit { 2 }

    trait :with_tasks do
      after(:create) do |project|
        create_list(:task, 3, project: project, user: project.users.first || create(:user))
      end
    end

    trait :at_wip_limit do
      after(:create) do |project|
        create_list(:task, project.wip_limit, :in_progress, project: project, user: project.users.first || create(:user))
      end
    end

    trait :invalid do
      name { nil }
    end
  end
end
