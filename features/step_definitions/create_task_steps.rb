# features/step_definitions/create_task_steps.rb

# GIVEN: A project needs to exist. This will fail if the Project Model
# or migration is missing, yielding a RED state.
Given('a project named {string} exists') do |name|
  # Attempts to create a Project record. This line will cause a Failure (RED).
  @project = Project.create!(name: name)
end

# GIVEN: Navigates to the tasks page. This will fail if the routes/controller
# are not defined, yielding a RED state.
And('I am on the {string} project\'s tasks page') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  # Attempts to visit the page. This line will cause a Failure (RED).
  visit project_tasks_path(@project)
end

# WHEN: Standard Capybara action to click a button or link.
When('I click {string}') do |button_or_link|
  click_on button_or_link
end

# WHEN: Standard Capybara action to select an option from a dropdown.
When('I select {string} from {string}') do |value, field|
  select value, from: field
end

# WHEN: Fills a field with an empty string, used for validation failure scenarios.
When('I leave {string} blank') do |field|
  fill_in field, with: ''
end

# THEN: Checks if the newly created task is present in the list display.
And('I should see the task in the list for project {string}') do |project_name|
  # Assumes the task list element will have a specific ID/CSS class.
  expect(page).to have_css("##{project_name.parameterize.underscore}_tasks_list")
end
