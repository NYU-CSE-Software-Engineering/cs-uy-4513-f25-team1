Given("I am a signed-in user") do
  step "I am a logged in user"
end

When("I go to the new project page") do
  visit path_to("the new project page")
end

Then("I should see the board columns:") do |table|
  table.raw.flatten.each do |column_name|
    expect(page).to have_css('.board-column .column-title', text: column_name)
  end
end
