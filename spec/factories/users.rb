FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    username { Faker::Internet.username }
    password { "password" }
    password_confirmation { "password" }
  end
end
