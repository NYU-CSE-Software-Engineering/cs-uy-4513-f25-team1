Feature: Projects UI
  As a signed-in user
  I want to create and configure projects
  So I can manage work on boards

  Background:
    Given I am a logged in user

  Scenario: Create a project successfully
    When I go to the projects page
    And I click the new project button
    And I fill in the project form with:
      | Name        | Alpha        |
      | Description | Alpha proj   |
    And I submit the create project form
    Then I should see "Project was successfully created."
    And I should be on the project page

  Scenario: Fail to create a project without name
    When I go to the projects page
    And I click the new project button
    And I submit the create project form
    Then I should see "Name can't be blank"

