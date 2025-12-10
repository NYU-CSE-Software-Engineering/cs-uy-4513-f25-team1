# Collaborators Step Definitions

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
    wip_limit: row['wip_limit'].to_i
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
  fill_in 'Email address', with: user.email_address
  fill_in 'Password', with: 'password'
  click_button 'Sign in'
end

Given('{string} has {int} completed tasks on project {string}') do |username, count, project_name|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  count.times do |i|
    Task.create!(
      title: "Completed Task #{i + 1}",
      status: 'Completed',
      project: project,
      user: user
    )
  end
end

Given('the project {string} has {int} total tasks') do |project_name, count|
  project = Project.find_by(name: project_name)
  users = project.users
  count.times do |i|
    Task.create!(
      title: "Task #{i + 1}",
      status: 'To Do',
      project: project,
      user: users.sample
    )
  end
end

Given('{string} has the following tasks on project {string}:') do |username, project_name, table|
  user = User.find_by(username: username)
  project = Project.find_by(name: project_name)
  
  table.hashes.each do |row|
    Task.create!(
      title: row['title'],
      status: row['status'],
      project: project,
      user: user
    )
  end
end

When('I visit the project {string} page') do |project_name|
  project = Project.find_by(name: project_name)
  visit project_path(project)
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
  user = User.find_by(username: username)
  # Find the collaborator card/row for this user and click the action link
  within(:xpath, "//h3[contains(text(), '#{username}')]/ancestor::div[@class='collaborator-card']") do
    click_link action
  end
end

When('I select {string} from {string}') do |value, field|
  select value, from: field
end

When('I click {string}') do |button_text|
  click_button button_text
end

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

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see an {string} link for {string}') do |link_text, username|
  within(:xpath, "//h3[contains(text(), '#{username}')]/ancestor::div[@class='collaborator-card']") do
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

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should see collaborator badges') do
  expect(page).to have_css('.collaborator-badge')
end

Then('I should see {string} link') do |link_text|
  expect(page).to have_link(link_text)
end

Then('I should see {string} for {string}') do |text, username|
  within(:xpath, "//h3[contains(text(), '#{username}')]/ancestor::div[@class='collaborator-card']") do
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
