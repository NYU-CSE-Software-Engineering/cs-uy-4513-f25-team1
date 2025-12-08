# Cucumber Step Definitions for the task limit feature.
# Tests WIP limit enforcement when moving tasks to "In Progress"

require 'capybara/cucumber'

# Helper method to retrieve the current project instance
def current_project
  @project || Project.last
end

# Helper to get or create a test user
def test_user
  @user ||= User.find_or_create_by!(email_address: 'wip_test@example.com') do |u|
    u.username = 'wip_tester'
    u.password = 'SecurePassword123'
  end
end

# Helper to sign in
def sign_in_test_user
  visit '/session/new'
  fill_in 'email_address', with: 'wip_test@example.com'
  fill_in 'password', with: 'SecurePassword123'
  click_button 'Sign in'
end

# --- Setup & Action Steps ---

# Defines a project with WIP limit
Given('a project named {string} exists with WIP limit {int}') do |name, limit|
  test_user # ensure user exists
  @project = Project.create!(name: name, wip_limit: limit)
end

# Navigation step for the project board
Given('I am on the {string} project board') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  sign_in_test_user
  visit project_path(@project)
end

# Creates the pre-existing tasks that satisfy the WIP limit
Given('there are already {int} tasks in status {string}') do |count, status|
  project = current_project

  current_count = project.tasks.where(status: status).count
  if current_count < count
    (count - current_count).times do |i|
      project.tasks.create!(
        title: "Pre-existing Task #{i + 1}",
        status: status,
        user: test_user
      )
    end
  end
  expect(project.tasks.where(status: status).count).to eq(count)
end

# Creates the task that will be moved to trigger the limit check
Given('I should see a task titled {string} in status {string}') do |title, status|
  current_project.tasks.find_or_create_by!(title: title) do |t|
    t.status = status
    t.user = test_user
  end
end

# Simulates the user moving a task via the edit form (Update action)
When('I move {string} to {string}') do |task_title, target_status|
  task = current_project.tasks.find_by!(title: task_title)

  # Go to the edit page, change the status, and submit the form
  visit edit_project_task_path(current_project, task)
  select target_status, from: 'task_status'
  click_button 'Update Task'
end

# --- Assertion Steps (Checking Controller and Model Outcomes) ---

# Checks for the expected error message when the WIP limit is hit
Then('I should see {string} limit {int} reached for {string}') do |limit_type, limit_value, status|
  # We expect an error message to be displayed on the screen
  expect(page).to have_content("WIP limit has been reached for this project.")
end

# Checks that the task status in the database is the OLD status
Then('{string} should remain in {string}') do |task_title, expected_status|
  # Database State Check
  task = current_project.tasks.find_by!(title: task_title)
  task.reload

  expect(task.status).to eq(expected_status),
    "Expected status '#{expected_status}' but was '#{task.status}'. "\
    "The WIP limit check should have prevented the task from moving."

  # UI State Check - Verify the task is still in the old column
  visit project_path(current_project)
  column_id = case expected_status
              when "In Progress" then "in-progress-column"
              when "To Do" then "to-do-column"
              when "In Review" then "in-review-column"
              when "Completed" then "completed-column"
              else expected_status.parameterize + "-column"
              end

  within("##{column_id}") do
    expect(page).to have_content(task_title)
  end
end
