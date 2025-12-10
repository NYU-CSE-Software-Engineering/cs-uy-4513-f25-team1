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
empty_project = FactoryBot.create(:project, name: "Empty Project", description: "An empty project for testing")
Collaborator.create!(user: main_user, project: empty_project, role: :manager)

# 2. Standard Project (Mixed tasks)
standard_project = FactoryBot.create(:project, name: "Standard Project", description: "A standard project with mixed tasks")
Collaborator.create!(user: main_user, project: standard_project, role: :manager)
Collaborator.create!(user: users.first, project: standard_project, role: :developer)

FactoryBot.create_list(:task, 3, :todo, project: standard_project, user: main_user)
FactoryBot.create_list(:task, 2, :in_progress, project: standard_project, user: users.first)
FactoryBot.create_list(:task, 2, :done, project: standard_project, user: main_user)

# 3. Busy Project
busy_project = FactoryBot.create(:project, name: "Busy Project", description: "A busy project with many tasks")
Collaborator.create!(user: main_user, project: busy_project, role: :manager)
FactoryBot.create_list(:task, 2, :in_progress, project: busy_project, user: main_user)
FactoryBot.create_list(:task, 3, :todo, project: busy_project, user: main_user)

# 4. Completed Project
completed_project = FactoryBot.create(:project, name: "Completed Project", description: "A project with all tasks completed")
Collaborator.create!(user: main_user, project: completed_project, role: :manager)
FactoryBot.create_list(:task, 5, :done, project: completed_project, user: main_user)

# 5. Invite Test Project (main_user is invited by another user)
inviter = FactoryBot.create(:user, email_address: "inviter@example.com", username: "inviter", password: "password", password_confirmation: "password")
invite_project = FactoryBot.create(:project, name: "Invite Test Project", description: "Project for testing invites")
Collaborator.create!(user: inviter, project: invite_project, role: :manager)
Collaborator.create!(user: main_user, project: invite_project, role: :invited)

puts "Seeding completed!"
puts "Main User: test@example.com / password"
puts "Inviter User: inviter@example.com / password"
