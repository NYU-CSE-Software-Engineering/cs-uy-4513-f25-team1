Given('I am a logged out user') do
  visit "/"
  if page.has_content?('Logout') then click_button 'Logout' end
end

Given('I am on the login page') do
  visit "/session/new"
end

When('I input valid inputs for fields email username password repeated_password') do
  fill_in 'email_address', with: "example@gmail.com"
  fill_in 'Username', with: "exampleUser"
  fill_in 'password', with: 'securePassword'
  fill_in 'Repeated password', with: 'securePassword'
end

Then('I should be on the page login\/signin') do
  expect(page).to have_current_path(sign_in_path)
end

Then('my account should be in the Users table') do
  @user = User.find_by(email: "example@gmail.com")
  expect(@user).not_to be_nil
  expect(@user.username).to eq('exampleUser')
end

When('I input an invalid email with other valid fields') do
  fill_in 'email_address', with: "Invalid"
  fill_in 'Username', with: "exampleUser"
  fill_in 'password', with: 'securePassword'
  fill_in 'Repeated Password', with: 'securePassword'
end

Then('I should be on the page login\/create') do
  expect(page).to have_current_path(create_account_path)
end


When('I input a taken email with other valid fields') do
  @user = User.create!(
    email_address: 'taken@gmail.com',
    username: 'user',
    password: 'securePassword'
  )
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'Password', with: "longpassword"
  fill_in 'Repeat password', with: "longpassword"
end

When('I input an invalid password with other valid fields') do
  fill_in 'email_address', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'password', with: "pass"
  fill_in 'Repeated Password', with: "password"
end

When('I input an invalid repeated_password with other valid fields') do
  fill_in 'email_address', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'password', with: "password"
  fill_in 'Repeated Password', with: "pass"
end

Then('I should be on the edit page') do
  expect(page).to have_content('Settings')
end

When('I make an account with email, username, password: {string} {string} {string}') do |email, username, password|
  visit new_user_path
  fill_in 'user_email_address', with: email
  fill_in 'user_username', with: username
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with: password
  click_button 'Create Account'
end

And('I log into an account with email, username, password: {string} {string} {string}') do |email, username, password|
  visit new_session_path
  fill_in 'email_address', with: email
  fill_in 'password', with: password
  click_button 'Sign in'
end

And('I edit my account with email, username, password: {string} {string} {string}') do |email, username, password|
  visit projects_path
  click_link 'User Settings'
  fill_in 'user_email_address', with: email
  fill_in 'user_username', with: username
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with: password
  click_button 'Update Account'
end

And('I log out') do
  visit projects_path
  click_button 'Log out'
end

Given('I am a logged in user') do
  @user = User.create!(
    email_address: 'taken@gmail.com',
    username: 'user',
    password: 'SecurePassword'
  )
  visit '/session/new'
  fill_in 'email_address', with: 'taken@gmail.com'
  fill_in 'password', with: 'SecurePassword'
  click_button 'Sign in'
  expect(page).to have_content('Log out')
end

Then('I should be on the projects page') do
  expect(page).to have_current_path("/projects")
end

Then('I should be on the home page') do
  expect(page).to have_current_path("/")
end

When('I go to my projects page') do
  visit projects_path
end

Then('I should see an error page') do
  expect(page).to have_content("Error:")
end

When('I input valid email and password') do
  @user = User.create!(
    email_address: 'taken@gmail.com',
    username: 'user',
    password: 'SecurePassword'
  )
  fill_in 'email_address', with: 'taken@gmail.com'
  fill_in 'password', with: 'SecurePassword'
end

When('I input invalid email and password') do
  fill_in 'email_address', with: 'lol'
  fill_in 'password', with: 'password'
end

When('I input wrong password with email') do
  @user = User.create!(
    email_address: 'taken@gmail.com',
    username: 'user',
    password: 'SecurePassword'
  )
  fill_in 'email_address', with: 'taken@gmail.com'
  fill_in 'password', with: 'wrongPassword'
end

Then('I should be on the home page signed in') do
  expect(page).to have_current_path("/")
  expect(page).to have_content("Log out")
end

Then('I should be on the login page') do
  expect(page).to have_current_path("/session/new")
end

Given('I am on the register page') do
  visit new_user_path
end

When('I type for email username password repeat-password {string} {string} {string} {string}') do |email, username, password, repeat_password|
  fill_in 'user_email_address', with: email
  fill_in 'user_username', with: username
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with: repeat_password
end

Then('I should be on the same register page') do
  expect(page).to have_content("Register")
end
