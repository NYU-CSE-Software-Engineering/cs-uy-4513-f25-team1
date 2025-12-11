When("I go to the projects page") do
  visit projects_path
end

When("I click the new project button") do
  # The new project button is an icon button with class 'add-project-btn'
  find('.add-project-btn').click
end

When("I fill in the project form with:") do |table|
  data = table.rows_hash
  fill_in 'project_name', with: data['Name'] if data['Name']
  fill_in 'project_description', with: data['Description'] if data['Description']
  # Note: Key field was removed from the project form
end

When("I submit the create project form") do
  click_button 'Create Project'
end

Then("I should see a notice {string}") do |text|
  expect(page).to have_css('.notice', text: text)
end

Then("I should see an alert {string}") do |text|
  expect(page).to have_css('.alert', text: text)
end

Then("I should be on the project page") do
  expect(page).to have_current_path(%r{^/projects/\d+$})
end

Then("I should see the status columns:") do |table|
  expected = table.raw.flatten
  titles = page.all('.board-column .column-title').map(&:text)
  expect(titles).to include(*expected)
end

Given("a project exists") do
  # Placeholder: ensure a project is present for navigation
end

When("I go to the project settings page") do
  visit edit_project_path(@project)
end

When("I save project settings") do
  find('#save-project-settings').click
end

Given("a project exists and I am not an admin") do
  # Placeholder: set role to non-admin in test stub
end
