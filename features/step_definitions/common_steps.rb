When('I click {string}') do |button_or_link|
  click_on button_or_link
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then('I should be on the page {string}') do |page_path|
  expect(page).to have_current_path(page_path)
end
