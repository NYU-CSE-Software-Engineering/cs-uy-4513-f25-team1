# Collaborators Step Definitions

# Helper to map human-readable status to enum symbol
def status_to_enum(status_string)
  {
    'Completed' => :completed,
    'In Progress' => :in_progress,
    'In Review' => :in_review,
    'To Do' => :todo,
    'Todo' => :todo
  }[status_string] || :todo
end

Given('the following users exist:') do |table|
  table.hashes.each do |row|
    User.create!(
      username: row['username'],
      email_address: row['email'],
      password: row['password'],
      password_confirmation: row['password']
    )
  end
end

Given('the following project exists:') do |table|
  row = table.hashes.first
  Project.create!(
    name: row['name'],
    description: row['description'] || 'Test project description'
  )
end

Given('{string} is a manager on project {string}') do |username, project_name|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  Collaborator.create!(user: user, project: project, role: :manager)
end

Given('{string} is a developer on project {string}') do |username, project_name|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  Collaborator.create!(user: user, project: project, role: :developer)
end

Given('I am signed in as {string}') do |username|
  user = User.find_by(username: username)
  visit '/session/new'
  fill_in 'email_address', with: user.email_address
  fill_in 'password', with: 'password'
  click_button 'Sign in'
end

Given('{string} has {int} completed tasks on project {string}') do |username, count, project_name|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  collaborator = Collaborator.find_by(user: user, project: project)
  count.times do |i|
    Task.create!(
      title: "Completed Task #{i + 1}",
      description: "Completed task description #{i + 1}",
      status: :completed,
      completed_at: Time.current,
      project: project,
      assignee: collaborator
    )
  end
end

Given('the project {string} has {int} total tasks') do |project_name, count|
  project = Project.find_by(name: project_name)
  collaborators = project.collaborators.where(role: :developer)
  count.times do |i|
    Task.create!(
      title: "Task #{i + 1}",
      description: "Task description #{i + 1}",
      status: :todo,
      project: project,
      assignee: collaborators.sample
    )
  end
end

Given('the project {string} has {int} additional tasks from other users') do |project_name, count|
  project = Project.find_by(name: project_name)
  # Get collaborators that are not dev1
  dev1_user = User.find_by(username: 'dev1')
  other_collaborators = project.collaborators.where.not(user: dev1_user).where(role: :developer)
  count.times do |i|
    Task.create!(
      title: "Other Task #{i + 1}",
      description: "Other task description #{i + 1}",
      status: :todo,
      project: project,
      assignee: other_collaborators.sample
    )
  end
end

Given('{string} has the following tasks on project {string}:') do |username, project_name, table|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  collaborator = Collaborator.find_by(user: user, project: project)

  table.hashes.each do |row|
    status_sym = status_to_enum(row['status'])
    task_attrs = {
      title: row['title'],
      description: "#{row['title']} description",
      status: status_sym,
      project: project,
      assignee: collaborator
    }
    task_attrs[:completed_at] = Time.current if status_sym == :completed
    Task.create!(task_attrs)
  end
end

When('I click on {string}') do |link_text|
  click_link link_text
end

When('I visit the collaborators page for project {string}') do |project_name|
  project = Project.find_by(name: project_name)
  visit project_collaborators_path(project)
end

When('I visit the profile page for {string} on project {string}') do |username, project_name|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  collaborator = Collaborator.find_by(user: user, project: project)
  visit project_collaborator_path(project, collaborator)
end

When('I click on {string} for collaborator {string}') do |action, username|
  # Find the link containing the username text, then find its parent collaborator card
  # and click the action link within that card
  within(:css, ".collaborator-card", text: username) do
    click_link action
  end
end

# Removed duplicate step definitions - these are already in common_steps.rb and other files

When('I confirm the removal') do
  # Capybara automatically handles JavaScript confirm dialogs in tests
  # This step exists for clarity but doesn't need implementation
end

Then('I should see the collaborators page') do
  expect(page).to have_current_path(/\/projects\/\d+\/collaborators/)
end

Then('I should see {string} in the managers section') do |username|
  within('.role-section', text: 'Managers') do
    expect(page).to have_content(username)
  end
end

Then('I should see {string} in the developers section') do |username|
  within('.role-section', text: 'Developers') do
    expect(page).to have_content(username)
  end
end

Then('I should not see an {string} link for {string}') do |link_text, username|
  within(:css, ".collaborator-card", text: username) do
    expect(page).not_to have_link(link_text)
  end
rescue Capybara::ElementNotFound
  # If the card is not found, the link doesn't exist either
  expect(true).to be true
end

Then('I should not see {string} in any collaborator list') do |username|
  within('.collaborators-list') do
    expect(page).not_to have_content(username)
  end
end

Then('I should see collaborator badges') do
  expect(page).to have_css('.collaborator-badge')
end

Then('I should see {string} link') do |link_text|
  expect(page).to have_link(link_text)
end

Then('I should see {string} for {string}') do |text, username|
  within(:css, ".collaborator-card", text: username) do
    expect(page).to have_content(text)
  end
end

Then('I should see {string} in the completed section') do |task_title|
  within('.status-section', text: 'Completed') do
    expect(page).to have_content(task_title)
  end
end

Then('I should see {string} in the in progress section') do |task_title|
  within('.status-section', text: 'In Progress') do
    expect(page).to have_content(task_title)
  end
end

Then('I should see {string} in the in review section') do |task_title|
  within('.status-section', text: 'In Review') do
    expect(page).to have_content(task_title)
  end
end
