When("I create a card in {string} with:") do |column_name, table|
  # TODO: implement UI interaction to create a card in the given column
end

Then("I should see a card titled {string} in {string}") do |title, column_name|
  within(find('.board-column', text: column_name)) do
    expect(page).to have_css('.card', text: title)
  end
end

Then("I should not see a card titled {string} in {string}") do |title, column_name|
  within(find('.board-column', text: column_name)) do
    expect(page).to have_no_css('.card', text: title)
  end
end

Given("a card titled {string} exists in {string}") do |title, column_name|
  # TODO: seed a card in the given column for test data
end

When("I rename the card {string} to {string}") do |old_title, new_title|
  # TODO: implement UI interaction to rename a card
end

When("I delete the card titled {string}") do |title|
  # TODO: implement UI interaction to delete a card
end
