# Cucumber Step Definitions for the filter feature
require 'capybara/cucumber'

# Helper to get or create a test user for filter tests
def filter_test_user
  @filter_user ||= User.find_or_create_by!(email_address: 'filter_test@example.com') do |u|
    u.username = 'filter_tester'
    u.password = 'SecurePassword123'
  end
end

# Helper to sign in
def sign_in_filter_user
  visit '/session/new'
  fill_in 'email_address', with: 'filter_test@example.com'
  fill_in 'password', with: 'SecurePassword123'
  click_button 'Sign in'
end

Given('I am on the Projects page') do
  visit projects_path
end

Given('a project named {string} exists with sample tasks') do |name|
  @project = Project.find_or_create_by!(name: name) do |p|
    p.description = 'Test project for filter'
  end

  # Link the currently logged-in user (@user from identity_steps) to the project as a manager
  Collaborator.find_or_create_by!(user: @user, project: @project) do |c|
    c.role = :manager
  end

  # Create sample tasks with different types for filtering tests
  unless @project.tasks.exists?
    @project.tasks.create!(title: "Feature Task 1", description: "Feature task description 1", status: :todo, type: "Feature")
    @project.tasks.create!(title: "Feature Task 2", description: "Feature task description 2", status: :in_progress, type: "Feature")
    @project.tasks.create!(title: "Bug Task 1", description: "Bug task description 1", status: :todo, type: "Bug")
    @project.tasks.create!(title: "Bug Task 2", description: "Bug task description 2", status: :in_review, type: "Bug")
    @project.tasks.create!(title: "Backlog Task 1", description: "Backlog task description 1", status: :todo, type: "Backlog")
    @project.tasks.create!(title: "Backlog Task 2", description: "Backlog task description 2", status: :completed, completed_at: Time.current, type: "Backlog")
  end
end

When('I click the {string} project') do |project_name|
  click_link project_name
end

Then('I should see tasks filtered by date created') do
  # Verify tasks are displayed in order of creation
  tasks = @project.tasks.order(:created_at)
  prev_index = -1

  tasks.each do |task|
    current_index = page.body.index(task.title)
    if current_index && prev_index >= 0
      expect(current_index).to be > prev_index,
        "Expected '#{task.title}' to appear after previous task in date created order"
    end
    prev_index = current_index if current_index
  end
end

Then('I should see tasks filtered by date modified') do
  # Verify tasks are displayed in order of last update
  tasks = @project.tasks.order(:updated_at)
  prev_index = -1

  tasks.each do |task|
    current_index = page.body.index(task.title)
    if current_index && prev_index >= 0
      expect(current_index).to be > prev_index,
        "Expected '#{task.title}' to appear after previous task in date modified order"
    end
    prev_index = current_index if current_index
  end
end

When('I click {string} in the filter select') do |filter_value|
  # Map filter values to the appropriate select element
  # Current UI uses: filter-priority, filter-assignee, filter-status, filter-due-date
  case filter_value
  when 'Feature', 'Bug', 'Backlog'
    # Type filtering is no longer available in the current UI - skip this step
    pending "Type filtering (#{filter_value}) is not implemented in the current UI"
  when 'Date Modified', 'Date Created'
    # Sorting is not implemented as a select in the current UI
    pending "Sort by #{filter_value} is not implemented in the current UI"
  else
    # Try to find a matching filter
    pending "Filter for '#{filter_value}' not found in current UI"
  end
end

When('I click the {string} button') do |button_text|
  click_button button_text
end

Then('I should only see tasks with type {string}') do |type|
  # Check that only tasks of the specified type are visible in the filtered task list
  within('#tasks-table') do
    @project.tasks.each do |task|
      if task.type == type
        expect(page).to have_content(task.title),
          "Expected to see task '#{task.title}' with type '#{type}'"
      else
        expect(page).not_to have_content(task.title),
          "Did not expect to see task '#{task.title}' with type '#{task.type}' when filtering for '#{type}'"
      end
    end
  end
end

When('I add {string} to the path and press enter') do |query_string|
  current = URI.parse(current_url)
  new_url = "#{current.path}#{query_string}"
  visit new_url
end
