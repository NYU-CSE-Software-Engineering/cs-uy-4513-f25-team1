Given('I am a signed in user') do
 @user = User.create!(email: 'test@example.com', password: 'password')
 visit new_user_session_path
 fill_in 'Email', with: @user.email
 fill_in 'Password', with: @user.password
 click_button 'Log in'
end

Given('I am on the Projects page') do
  visit projects_path
end


And('I click the {string} project') do |project|
  click_button project
end

Then('I should see tasks filtered by date created') do
  prev = ""
  Task.order(:created_at).find_each do |task|
    if prev != ""
      expect(page.body.index(prev)).to be < page.body.index(task.desc)
    end
    prev = task.desc
  end
end

Then('I should see tasks filtered by date modified') do
  prev = ""
  Task.order(:date_modified).find_each do |task|
    if prev != ""
      expect(page.body.index(prev)).to be < page.body.index(task.desc)
    end
    prev = task.desc
  end
end

When('I click {string} in the filter select') do |filter|
  page.select filter, from: 'filter'
end

When('I click the {string} button') do |btn|
  click_button btn
end

Then('I should only see tasks with type {string}') do |type|
  Task.find_each do |task|
    if task.type == type then
      expect(page).to have_content task.desc
    else
      expect(page).not_to have_content task.desc
    end
  end
end

And('I add {string} to the path and press enter') do |filter|
  url = URI.parse(current_url) + string
  visit url
end
