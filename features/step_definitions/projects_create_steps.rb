Given("I am a signed-in user") do
  sign_in_test_user
end

When("I go to the new project page") do
  visit path_to("the new project page")
end

Then("I should see the board columns:") do |table|
  # The view now uses IDs for columns
  table.raw.flatten.each do |column_name|
    column_id = case column_name
    when "To Do" then "to-do-column"
    when "In Progress" then "in-progress-column"
    when "Done" then "done-column"
    end
    expect(page).to have_css("##{column_id} .group-title", text: column_name)
  end
end
