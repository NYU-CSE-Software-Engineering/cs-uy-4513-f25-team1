When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

When('I press {string}') do |button|
  click_button button
end
