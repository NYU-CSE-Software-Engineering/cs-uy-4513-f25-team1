Given('I am signed in as a user') do
  # Mock sign in - User model missing
end

Given('I am on the new project page') do
  visit new_project_path
end

Given('an existing project with key {string} already exists') do |key|
  # Project model doesn't have key or created_by in current schema
  # Assuming name is used as key or key is missing
  Project.create!(
    name: "Project #{key}",
    wip_limit: 3
  )
end

Then('I should be on the project\'s show page') do
  expect(current_path).to match(%r{/projects/\d+})
end
