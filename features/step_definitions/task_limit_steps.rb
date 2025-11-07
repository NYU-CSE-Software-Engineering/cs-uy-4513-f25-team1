# Cucumber Step Definitions for the task limit feature, using Capybara to simulate 
# controller interaction as requested by the reviewer.

# Requires Capybara for simulating web interactions.
require 'capybara/cucumber' 
# Assuming your Rails environment is loaded for model access.

# Helper method to find the current project (if needed)
def current_project
  # This assumes @project is set in a previous step, or finds the last one.
  @project || Project.last
end

# --- Setup Steps ---

# Step 1: Given('a project named {string} exists with WIP limit {int}')
# Sets up the initial state of the project model.
Given('a project named {string} exists with WIP limit {int}') do |name, limit|
  @project = Project.create!(name: name, wip_limit: limit)
end

# Step 2: Given('I am on the {string} project\'s tasks page')
# Simulates visiting the project tasks index page.
Given('I am on the {string} project\'s tasks page') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  # Assumes a Rails route helper like project_tasks_path exists
  visit project_tasks_path(@project) 
end

# --- Action Steps (Using Capybara to simulate UI interaction) ---

# Step 3: When('I click the "New Task" button to create a task')
When('I click the {string} button to create a task') do |button_name|
  click_button button_name
end

# Step 4: When('I fill in the task form with title {string} and status {string}')
When('I fill in the task form with title {string} and status {string}') do |title, status|
  # Use the correct field labels from your application's form
  fill_in 'Task Title', with: title
  select status, from: 'Task Status'
end

# Step 5: When('I submit the task form')
When('I submit the task form') do
  # Simulates clicking the final submit button, which triggers the Controller#create action.
  click_button 'Create Task' 
end

# --- Assertion Steps (Checking Controller and Model Outcomes) ---

# Step 6: Then('I should see the task {string} in the list')
# Checks the UI for a successful outcome.
Then('I should see the task {string} in the list') do |task_title|
  # Expect the page content to contain the newly created task title
  expect(page).to have_content(task_title)
end

# Step 7: Then('I should see an error message indicating the WIP limit is reached')
# Checks the UI for a failed outcome (Controller redirecting back with errors).
Then('I should see an error message indicating the WIP limit is reached') do
  # Check for error messages displayed by the Rails application
  expect(page).to have_content("WIP limit has been reached for this project.")
  expect(page).to have_content("Task could not be created.")
end

# Step 8: Then('the number of tasks for the project should remain {int}')
# Direct model reference check to verify data persistence after controller action.
Then('the number of tasks for the project should remain {int}') do |expected_count|
  # Reload the project object from the database to get the latest count
  current_project.reload
  expect(current_project.tasks.count).to eq(expected_count)
end

# --- Auxiliary Steps (for setting up complex state) ---

# Example step for setting up the state where the limit is already hit
Given('the project already has {int} tasks with status {string}') do |count, status|
  project = current_project
  
  # Check if the project already has enough tasks, if not, create them
  if project.tasks.where(status: status).count < count
    (count - project.tasks.where(status: status).count).times do |i|
      project.tasks.create!(title: "Pre-existing Task #{i+1}", status: status)
    end
  end
  # Final verification of the setup state
  expect(project.tasks.where(status: status).count).to eq(count)
end

# Example of a fully integrated task creation step
When('I create a task titled {string}') do |title|
  visit new_project_task_path(current_project)
  fill_in 'Task Title', with: title
  select 'To Do', from: 'Task Status'
  click_button 'Create Task'
end
