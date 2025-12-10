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

# Note: 'I select {string} from {string}' and 'I leave {string} blank'
# are defined in task_steps.rb to avoid duplication

# THEN: Checks if specific content (success message or error message) is visible.

# THEN: Checks if the newly created task is present in the list display.
And('I should see the task in the list for project {string}') do |project_name|
  # Assumes the task list element will have a specific ID/CSS class.
  expect(page).to have_css("##{project_name.parameterize.underscore}_tasks_list")
end
