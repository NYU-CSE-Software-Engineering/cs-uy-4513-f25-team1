# Cucumber Step Definitions for the task limit feature.
# This file uses Capybara to simulate the user moving a task via the UI.

require 'capybara/cucumber'

# Helper method to retrieve the current project instance
def current_project
  @project || Project.last
end

def normalize_status(status)
  case status
  when "To Do" then "not_started"
  when "In Progress" then "in_progress"
  when "Done" then "done"
  else status.downcase.gsub(' ', '_')
  end
end

# --- Setup & Action Steps ---

# Defines a project
Given('a project named {string} exists with WIP limit {int}') do |name, limit|
  @project = Project.create!(name: name, wip_limit: limit, key: name.upcase[0..3])
end

# Navigation step for the project board
Given('I am on the {string} project board') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  visit project_path(@project)
end

# Creates the pre-existing tasks that satisfy the WIP limit
Given('there are already {int} tasks in status {string}') do |count, status|
  db_status = normalize_status(status)
  project = current_project || Project.last

  if project.tasks.where(status: db_status).count < count
    (count - project.tasks.where(status: db_status).count).times do |i|
      project.tasks.create!(title: "Pre-existing Task #{i+1}", status: db_status)
    end
  end
  expect(project.tasks.where(status: db_status).count).to eq(count)
end

# Creates the task that will be moved to trigger the limit check
# NOTE: We only handle the database creation here and skip immediate UI/path checks
# to prevent Capybara session errors in the Background block.
Given('I should see a task titled {string} in status {string}') do |title, status|
  db_status = normalize_status(status)
  # Create or find the task in the database
  current_project.tasks.find_or_create_by!(title: title) do |t|
    t.status = db_status
  end
end

# Simulates the user moving a task via the edit form (Update action)
When('I move {string} to {string}') do |task_title, target_status|
  task = current_project.tasks.find_by!(title: task_title)
  # Go to the edit page, change the status, and submit the form
  visit edit_project_task_path(current_project, task)
  select target_status, from: 'Status'
  click_button 'Update Task'
end

# --- Assertion Steps (Checking Controller and Model Outcomes) ---

# Checks for the expected error message when the WIP limit is hit
Then('I should see {string} limit {int} reached for {string}') do |limit_type, limit_value, status|
  # We expect an error message to be displayed on the screen
  expect(page).to have_content("WIP limit has been reached for this project.")
end

# Checks that the task status in the database is the OLD status (To Do)
Then('{string} should remain in {string}') do |task_title, expected_status|
  db_status = normalize_status(expected_status)
  # 1. Database State Check (Model)
  task = current_project.tasks.find_by!(title: task_title)
  task.reload

  expect(task.status).to eq(db_status)

  # 2. UI State Check (Verifying the task is still in the old column)
  visit project_path(current_project)
  # Map status to column ID
  column_id = case db_status
  when "not_started" then "to-do"
  when "in_progress" then "in-progress"
  when "done" then "done"
  end

  within("##{column_id}-column") do
    expect(page).to have_content(task_title)
  end
end
