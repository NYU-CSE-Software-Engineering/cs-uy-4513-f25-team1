Given('I am a logged out user') do
  visit "/"
  if page.has_content?('Logout') then click_button 'Logout' end
end

Given('I am on the login page') do
  visit "/session/new"
end

Given('I am on the page {string}') do |page_path|
  visit page_path
end

When('I input valid inputs for fields email username password repeated_password') do
  fill_in 'Email', with: "example@gmail.com"
  fill_in 'Username', with: "exampleUser"
  fill_in 'Password', with: 'securePassword'
  fill_in 'Repeat password', with: 'securePassword'
end

Then('my account should be in the Users table') do
  @user = User.find_by(email: "example@gmail.com")
  expect(@user).not_to be_nil
  expect(@user.username).to eq('exampleUser')
end

When('I input an invalid email with other valid fields') do
  fill_in 'Email', with: "Invalid"
  fill_in 'Username', with: "exampleUser"
  fill_in 'Password', with: 'securePassword'
  fill_in 'Repeat password', with: 'securePassword'
end

When('I input a taken email with other valid fields') do
  @user = User.create!(
    email_address: 'taken@gmail.com',
    username: 'user',
    password_digest: 'securePassword'
  )
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'password', with: "password"
  fill_in 'Repeat password', with: "password"
end

When('I input an invalid password with other valid fields') do
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'password', with: "pass"
  fill_in 'Repeat password', with: "password"
end

When('I input an invalid repeated_password with other valid fields') do
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'password', with: "password"
  fill_in 'Repeat password', with: "pass"
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
  fill_in 'Email', with: 'taken@gmail.com'
  fill_in 'password', with: 'SecurePassword'
end

When('I input invalid email and password') do
  fill_in 'Email', with: 'lol'
  fill_in 'password', with: 'password'
end

When('I input wrong password with email') do
  @user = User.create!(
    email_address: 'taken@gmail.com',
    username: 'user',
    password: 'SecurePassword'
  )
  fill_in 'Email', with: 'taken@gmail.com'
  fill_in 'password', with: 'wrongPassword'
end

Then('I should be on the home page signed in') do
  expect(page).to have_current_path("/")
  expect(page).to have_content("Log out")
end

Then('I should be on the login page') do
  expect(page).to have_current_path("/session/new")
end
