# features/step_definitions/task_management_steps.rb

require 'capybara/cucumber'

# Helper to create and sign in a user with a specific role on a project
def create_user_with_role(role, project_name)
  @user = User.create!(
    email_address: "#{role}_user_#{SecureRandom.hex(4)}@example.com",
    username: "#{role}_user_#{SecureRandom.hex(4)}",
    password: 'SecurePassword123'
  )

  @project = Project.find_or_create_by!(name: project_name) do |p|
    p.description = "Test project #{project_name}"
  end

  Collaborator.create!(
    user: @user,
    project: @project,
    role: role
  )

  sign_in_user(@user)
end

def sign_in_user(user)
  visit '/session/new'
  fill_in 'email_address', with: user.email_address
  fill_in 'password', with: 'SecurePassword123'
  click_button 'Sign in'
end

# Background steps for role-based login
Given('I am logged in as a manager on project {string}') do |project_name|
  create_user_with_role(:manager, project_name)
  visit project_path(@project)
end

Given('I am logged in as a developer on project {string}') do |project_name|
  create_user_with_role(:developer, project_name)
  visit project_path(@project)
end

Given('I am logged in as an invited user on project {string}') do |project_name|
  create_user_with_role(:invited, project_name)
  visit project_path(@project)
end

# Create collaborators on existing project
Given('a developer {string} exists on project {string}') do |username, project_name|
  @project ||= Project.find_by!(name: project_name)
  dev_user = User.create!(
    email_address: "#{username}@example.com",
    username: username,
    password: 'SecurePassword123'
  )
  Collaborator.create!(user: dev_user, project: @project, role: :developer)
end

Given('a manager {string} exists on project {string}') do |username, project_name|
  @project ||= Project.find_by!(name: project_name)
  manager_user = User.create!(
    email_address: "#{username}@example.com",
    username: username,
    password: 'SecurePassword123'
  )
  Collaborator.create!(user: manager_user, project: @project, role: :manager)
end

# Task creation with attributes
Given('a task {string} exists on project {string} with:') do |title, project_name, table|
  @project ||= Project.find_by!(name: project_name)
  attrs = table.rows_hash.symbolize_keys
  @task = @project.tasks.create!(
    title: title,
    description: attrs[:description] || "Default description",
    type: attrs[:type],
    branch_link: attrs[:branch_link],
    priority: attrs[:priority] || :no_priority,
    status: attrs[:status] || :todo
  )
end

Given('a completed task {string} exists on project {string} with:') do |title, project_name, table|
  @project ||= Project.find_by!(name: project_name)
  attrs = table.rows_hash.symbolize_keys
  @task = @project.tasks.create!(
    title: title,
    description: attrs[:description] || "Default description",
    type: attrs[:type],
    branch_link: attrs[:branch_link],
    priority: attrs[:priority] || :no_priority,
    status: :completed,
    completed_at: Time.current
  )
end

# Navigation steps
When('I visit the project {string} page') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  visit project_path(@project)
end

When('I visit the new task page for project {string}') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  visit new_project_task_path(@project)
end

When('I visit the task page for {string} on project {string}') do |task_title, project_name|
  @project ||= Project.find_by!(name: project_name)
  task = @project.tasks.find_by!(title: task_title)
  visit project_task_path(@project, task)
end

# Page location assertions
Then('I should be on the new task page for project {string}') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  expect(page).to have_current_path(new_project_task_path(@project))
end

Then('I should be on the project {string} page') do |project_name|
  @project ||= Project.find_by!(name: project_name)
  expect(page).to have_current_path(project_path(@project))
end

Then('I should be on the task page for {string}') do |task_title|
  task = Task.find_by!(title: task_title)
  expect(page).to have_current_path(project_task_path(task.project, task))
end

# Visibility assertions
Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

# Click on first matching task link
When('I click on the task {string}') do |task_title|
  first(:link, task_title).click
end

Then('I should see {string} in the assignee dropdown') do |username|
  within('select[name="task[assignee_id]"]') do
    expect(page).to have_content(username)
  end
end

Then('I should not see {string} in the assignee dropdown') do |username|
  within('select[name="task[assignee_id]"]') do
    expect(page).not_to have_content(username)
  end
end

Then('I should see {string} within the task list') do |text|
  within('#tasks-table') do
    expect(page).to have_content(text)
  end
end

Then('I should not see {string} within the task list') do |text|
  within('#tasks-table') do
    expect(page).not_to have_content(text)
  end
end

# Select from status filter dropdown (using element id)
When('I filter by status {string}') do |status_value|
  status_map = {
    'Completed' => 'completed',
    'In Progress' => 'in_progress',
    'In Review' => 'in_review',
    'To Do' => 'todo'
  }
  select status_value, from: 'filter-status'
  pending 'Status filtering requires JavaScript (add @javascript tag to scenario)' unless Capybara.current_driver == :selenium || Capybara.current_driver == :selenium_chrome || Capybara.current_driver == :selenium_headless
end

# Form interaction steps
When('I fill in the due date field with tomorrow\'s date') do
  tomorrow = (Date.today + 1).strftime('%Y-%m-%dT12:00')
  fill_in 'Due Date (optional)', with: tomorrow
end

# Task update steps using form submission (simulating inline edit via standard form)
When('I update task {string} with title {string}') do |task_title, new_title|
  @project ||= Project.first
  @task = @project.tasks.find_by!(title: task_title)
  visit project_task_path(@project, @task)
  page.driver.submit :patch, project_task_path(@project, @task), { task: { title: new_title } }
end

When('I update task {string} with status {string}') do |task_title, new_status|
  @project ||= Project.first
  @task = @project.tasks.find_by!(title: task_title)
  visit project_task_path(@project, @task)
  page.driver.submit :patch, project_task_path(@project, @task), { task: { status: new_status } }
end

When('I update task {string} with priority {string}') do |task_title, new_priority|
  @project ||= Project.first
  @task = @project.tasks.find_by!(title: task_title)
  visit project_task_path(@project, @task)
  page.driver.submit :patch, project_task_path(@project, @task), { task: { priority: new_priority } }
end

When('I update task {string} with:') do |task_title, table|
  @project ||= Project.first
  @task = @project.tasks.find_by!(title: task_title)
  attrs = table.rows_hash.symbolize_keys
  visit project_task_path(@project, @task)
  page.driver.submit :patch, project_task_path(@project, @task), { task: attrs }
end

# Try to update (for testing permission denied scenarios)
When('I try to update task {string} with title {string}') do |task_title, new_title|
  @project ||= Project.first
  @task = @project.tasks.find_by!(title: task_title)
  page.driver.submit :patch, project_task_path(@project, @task), { task: { title: new_title } }
end

Then('the task {string} should still have title {string}') do |expected_title, _|
  task = Task.find_by(title: expected_title)
  expect(task).to be_present
end

Then('the task should have title {string}') do |expected_title|
  @task.reload
  expect(@task.title).to eq(expected_title)
end
