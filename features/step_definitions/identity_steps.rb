Given('I am a logged out user') do
  visit root_path
  if page.has_content?('Logout') then click_button 'Logout' end
end

Given('I am on the page login\/create') do
  visit new_user_registration_path
end

When('I input valid inputs for fields email username password repeated_password') do
  fill_in 'Email', with: "example@gmail.com"
  fill_in 'Username', with: "exampleUser"
  fill_in 'Password', with: 'securePassword'
  fill_in 'Repeated Password', with: 'securePassword'
end


Then('I should be on the page login\/signin') do
  expect(page).to have_current_path(new_user_session_path)
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
  fill_in 'Repeated Password', with: 'securePassword'
end

Then('I should be on the page login\/create') do
  expect([ new_user_registration_path, '/users' ]).to include(page.current_path)
end


When('I input a taken email with other valid fields') do
  @user = User.create!(
    email: 'taken@gmail.com',
    password: 'password'
  )
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'Password', with: "password"
  fill_in 'Repeated Password', with: "password"
end

When('I input an invalid password with other valid fields') do
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'Password', with: "pass"
  fill_in 'Repeated Password', with: "password"
end

When('I input an invalid repeated_password with other valid fields') do
  fill_in 'Email', with: "taken@gmail.com"
  fill_in 'Username', with: "user"
  fill_in 'Password', with: "password"
  fill_in 'Repeated Password', with: "pass"
end

Given('I am a logged in user') do
  expect(page).to have_content('Log out')
end

Then('I should be on the home page') do
  expect(page).to have_current_path(root_path)
end

When('I go to my projects page') do
  visit user_project_path
end

Then('I should see an error page') do
  expect(page).to have_content("Error:")
end

Given('I am on the login page') do
  visit new_user_session_path
end

When('I input valid email and password') do
  @user = User.create!(
    email: 'taken@gmail.com',
    password: 'password'
  )
  fill_in 'Email', with: 'taken@gmail.com'
  fill_in 'Password', with: 'password'
end

When('I input invalid email and password') do
  fill_in 'Email', with: 'lol'
  fill_in 'Password', with: 'password'
end

When('I input wrong password with email') do
  @user = User.create!(
    email: 'taken@gmail.com',
    password: 'password'
  )
  fill_in 'Email', with: 'taken@gmail.com'
  fill_in 'Password', with: 'wrongPassword'
end

Then('I should be on the home page signed in') do
  expect(page).to have_current_path(root_path)
  expect(page).to have_content("Log out")
end

Then('I should be on the login page') do
  expect(page).to have_current_path(new_user_session_path)
end
