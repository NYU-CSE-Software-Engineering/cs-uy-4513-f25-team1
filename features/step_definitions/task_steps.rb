Given("a project named {string} exists") do |project_name|
  Project.create!(name: project_name)
end

Given("I am on the {string} project's tasks page") do |project_name|
  project = Project.find_by!(name: project_name)
  visit project_path(project)
end

When("I fill in {string} with {string}") do |field_name, value|
  fill_in field_name, with: value
end

When("I select {string} from {string}") do |option, field_name|
  select option, from: field_name
end


Then("I should see the task in the list for project {string}") do |project_name|
  project = Project.find_by!(name: project_name)
  expect(page).to have_current_path(project_tasks_path(project))
end

When("I leave {string} blank") do |field_name|
  fill_in field_name, with: ""
end
