# Clear existing data
puts "Cleaning database..."
Collaborator.destroy_all
Task.destroy_all
Project.destroy_all
User.destroy_all

puts "Creating users..."
users = FactoryBot.create_list(:user, 5)
main_user = FactoryBot.create(:user, email_address: "test@example.com", username: "tester", password: "password", password_confirmation: "password")
users << main_user

puts "Creating projects..."

# 1. Empty Project
empty_project = FactoryBot.create(:project, name: "Empty Project", wip_limit: 3)
Collaborator.create!(user: main_user, project: empty_project, role: :manager)

# 2. Standard Project (Mixed tasks)
standard_project = FactoryBot.create(:project, name: "Standard Project", wip_limit: 5)
Collaborator.create!(user: main_user, project: standard_project, role: :manager)
Collaborator.create!(user: users.first, project: standard_project, role: :developer)

FactoryBot.create_list(:task, 3, :todo, project: standard_project, user: main_user)
FactoryBot.create_list(:task, 2, :in_progress, project: standard_project, user: users.first)
FactoryBot.create_list(:task, 2, :done, project: standard_project, user: main_user)

# 3. Busy Project (At WIP Limit)
busy_project = FactoryBot.create(:project, name: "Busy Project", wip_limit: 2)
Collaborator.create!(user: main_user, project: busy_project, role: :manager)
# Create tasks exactly at WIP limit
FactoryBot.create_list(:task, 2, :in_progress, project: busy_project, user: main_user)
FactoryBot.create_list(:task, 3, :todo, project: busy_project, user: main_user)

# 4. Completed Project
completed_project = FactoryBot.create(:project, name: "Completed Project", wip_limit: 3)
Collaborator.create!(user: main_user, project: completed_project, role: :manager)
FactoryBot.create_list(:task, 5, :done, project: completed_project, user: main_user)

puts "Seeding completed!"
puts "Main User: test@example.com / password"
