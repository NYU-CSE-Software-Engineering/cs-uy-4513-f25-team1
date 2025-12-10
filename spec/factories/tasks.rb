FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { :todo }
    priority { :no_priority }
    association :project
    assignee { nil }

    # Status traits
    trait :todo do
      status { :todo }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :in_review do
      status { :in_review }
    end

    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end

    # Priority traits
    trait :no_priority do
      priority { :no_priority }
    end

    trait :low_priority do
      priority { :low }
    end

    trait :medium_priority do
      priority { :medium }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :urgent_priority do
      priority { :urgent }
    end

    # Due date traits
    trait :due_past do
      due_at { Faker::Time.backward(days: 14) }
    end

    trait :due_today do
      due_at { Time.current.end_of_day }
    end

    trait :due_soon do
      due_at { Faker::Time.forward(days: 7) }
    end

    trait :due_later do
      due_at { Faker::Time.forward(days: 30) }
    end

    # Branch link trait
    trait :with_branch do
      branch_link { "https://github.com/org/repo/tree/feature/#{Faker::Lorem.word}-#{Faker::Number.number(digits: 4)}" }
    end

    # Type traits
    trait :bug do
      type { "Bug" }
    end

    trait :feature do
      type { "Feature" }
    end

    trait :improvement do
      type { "Improvement" }
    end

    trait :chore do
      type { "Chore" }
    end

    trait :documentation do
      type { "Documentation" }
    end

    trait :with_assignee do
      transient do
        assignee_user { nil }
      end

      after(:build) do |task, evaluator|
        if evaluator.assignee_user
          collaborator = Collaborator.find_by(user: evaluator.assignee_user, project: task.project)
          collaborator ||= create(:collaborator, :developer, user: evaluator.assignee_user, project: task.project)
          task.assignee = collaborator
        end
      end
    end

    trait :invalid do
      title { nil }
    end
  end
end
