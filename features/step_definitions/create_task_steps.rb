# features/step_definitions/create_task_steps.rb

# GIVEN: A project needs to exist. This will fail if the Project Model
# or migration is missing, yielding a RED state.

# GIVEN: Navigates to the tasks page. This will fail if the routes/controller
# are not defined, yielding a RED state.

# WHEN: Standard Capybara action to fill in a text field.

# WHEN: Standard Capybara action to select an option from a dropdown.

# THEN: Checks if specific content (success message or error message) is visible.
# Then('I should see {string}') do |content|
#   expect(page).to have_content(content)
# end

# THEN: Checks if the newly created task is present in the list display.
