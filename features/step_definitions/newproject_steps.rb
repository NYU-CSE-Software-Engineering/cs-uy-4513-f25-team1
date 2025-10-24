Given('I am signed in as an admin') do
  @user = User.create!(
    email: 'admin@example.com',
    password: 'password',
    role: 'admin'
  )
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Log in'
end

Given('I am signed in as a developer') do
  @user = User.create!(
    email: 'dev@example.com',
    password: 'password',
    role: 'developer'
  )
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Log in'
end

Given('I am on the new project page') do
  visit new_project_path
end

Given('an existing project with key {string} already exists') do |key|
  Project.create!(
    name: 'Existing Project',
    key: key,
    description: 'Already taken project key',
    created_by: @user
  )
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press {string}') do |button|
  click_button button
end

Then('I should be on the project\'s show page') do
  expect(current_path).to match(%r{/projects/\d+})
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end
