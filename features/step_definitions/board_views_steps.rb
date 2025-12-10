When("I visit the board page for the project") do
  # Placeholder for visiting board UI
end

Then("I should see a column {string} with count {int}") do |status, count|
  within(find('.board-column', text: status)) do
    expect(page).to have_css('.wip-count', text: count.to_s)
  end
end

When("I apply the board filter for issue types {string}") do |types|
  # Placeholder to apply filter in UI
end

Then("I should not see a card of type {string}") do |type|
  expect(page).to have_no_css('.card[data-issue-type="' + type + '"]')
end
