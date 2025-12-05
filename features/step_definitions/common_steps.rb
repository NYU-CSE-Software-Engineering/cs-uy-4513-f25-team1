When('I click {string}') do |button_or_link|
  click_on button_or_link
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end
