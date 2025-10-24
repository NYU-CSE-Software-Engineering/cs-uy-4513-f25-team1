Given("I am a Project Admin of {string}") do |project_name|
  @current_project_name = project_name
  @current_role = 'admin'
end

Given("I am a Project Member (not admin) of {string}") do |project_name|
  @current_project_name = project_name
  @current_role = 'developer'
end

Given("the project has a board with columns:") do |table|
  @board_columns = table.raw.flatten
end

When("I add a column named {string}") do |name|
  add_column_via_ui(name)
end

When("I rename the column {string} to {string}") do |old_name, new_name|
  within(find('.board-column', text: old_name)) do
    find('.column-actions .rename-column').click
  end
  fill_in 'rename-column-input', with: new_name
  find('#confirm-rename-column').click
end

When("I delete the column {string}") do |name|
  page.accept_confirm do
    within(find('.board-column', text: name)) do
      find('.column-actions .delete-column').click
    end
  end
end

When("I move column {string} up") do |name|
  within(find('.board-column', text: name)) do
    find('.column-actions .move-up-column').click
  end
end

Then("I should see {string} in the board columns") do |name|
  expect(page).to have_css('.board-column .column-title', text: name)
end

Then("I should not see {string} in the board columns") do |name|
  expect(page).to have_no_css('.board-column .column-title', text: name)
end

Then("the column order should be:") do |table|
  expected = table.raw.flatten
  actual = page.all('.board-column .column-title').map(&:text)
  expect(actual).to eq(expected)
end


When("I try to add a column named {string}") do |name|
  add_column_via_ui(name)
end

def add_column_via_ui(name)
  find('#add-column-button').click
  fill_in 'new-column-name', with: name
  find('#confirm-add-column').click
end


