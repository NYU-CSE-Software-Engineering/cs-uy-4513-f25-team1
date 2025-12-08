FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { "Todo" }
    priority { "No Priority" }
    association :project
    assignee { nil }
    due_at { nil }
    branch_link { nil }

    trait :todo do
      status { "Todo" }
      assignee { nil }
    end

    trait :in_progress do
      status { "In Progress" }
      after(:build) do |task|
        task.assignee = create(:collaborator, project: task.project).id
      end
    end

    trait :in_review do
      status { "In Review" }
      after(:build) do |task|
        task.assignee = create(:collaborator, project: task.project).id
      end
    end

    trait :completed do
      status { "Completed" }
      after(:build) do |task|
        task.assignee = create(:collaborator, project: task.project).id
      end
    end

    trait :with_due_date do
      due_at { 1.week.from_now }
    end

    trait :with_branch_link do
      branch_link { "https://github.com/repo/branch" }
    end

    trait :high_priority do
      priority { "High" }
    end

    trait :urgent_priority do
      priority { "Urgent" }
    end

    trait :invalid do
      title { nil }
      description { nil }
    end
  end
end
