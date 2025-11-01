When("I go to the projects page") do
  visit path_to("the projects page")
end

When("I click the new project button") do
  find('#new-project-button').click
end

When("I fill in the project form with:") do |table|
  data = table.rows_hash
  fill_in 'project_name', with: data['Name'] if data['Name']
  fill_in 'project_key', with: data['Key'] if data['Key']
  fill_in 'project_description', with: data['Description'] if data['Description']
end

When("I submit the create project form") do
  find('#create-project-button').click
end

Then("I should see a notice {string}") do |text|
  expect(page).to have_css('.flash.notice', text: text)
end

Then("I should see an alert {string}") do |text|
  expect(page).to have_css('.flash.alert', text: text)
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
  visit path_to("the project settings page")
end

When("I set WIP limit for {string} to {int}") do |status, limit|
  within(".wip-limit-row[data-status='#{status}']") do
    fill_in 'wip_limit', with: limit
  end
end

When("I save project settings") do
  find('#save-project-settings').click
end

Then("visiting the project page shows WIP limits applied") do
  visit path_to("the project page")
  expect(page).to have_css(".board-column[data-status='in progress'] .wip-limit", text: /2/)
end

Given("a project exists and I am not an admin") do
  # Placeholder: set role to non-admin in test stub
end
