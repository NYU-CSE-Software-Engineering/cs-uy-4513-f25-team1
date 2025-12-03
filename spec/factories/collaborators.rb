FactoryBot.define do
  factory :collaborator do
    association :user
    association :project
    role { "owner" }
  end
end
