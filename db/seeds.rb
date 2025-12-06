# Clear existing data
Collaborator.destroy_all
Task.destroy_all
Project.destroy_all
User.destroy_all

# Create Users
manager = User.create!(
  email_address: "manager@example.com",
  password: "password",
  password_confirmation: "password",
  username: "ManagerUser"
)

dev = User.create!(
  email_address: "dev@example.com",
  password: "password",
  password_confirmation: "password",
  username: "DevUser"
)

new_user = User.create!(
  email_address: "new@example.com",
  password: "password",
  password_confirmation: "password",
  username: "NewUser"
)

# Create Projects for Manager
proj1 = Project.create!(name: "Alpha Project")
proj2 = Project.create!(name: "Beta Project")

# Assign Manager
Collaborator.create!(user: manager, project: proj1, role: "manager")
Collaborator.create!(user: manager, project: proj2, role: "manager")

# Assign Developer to Alpha
Collaborator.create!(user: dev, project: proj1, role: "developer")

# Create Project where Manager is Developer (unlikely but possible to test "Developer Projects" section for manager)
proj3 = Project.create!(name: "Gamma Service")
Collaborator.create!(user: manager, project: proj3, role: "developer")

puts "Seeding complete!"
puts "Manager: manager@example.com / password"
puts "Dev: dev@example.com / password"
puts "New User: new@example.com / password"
