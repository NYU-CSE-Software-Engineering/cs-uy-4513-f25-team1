Feature: Create a new project
  As a user
  I want to create a new project
  So that I can organize tasks and manage progress

  Scenario: Successfully create a new project
    Given I am a logged in user
    And I am on the new project page
    When I fill in "Name" with "Lira"
    And I fill in "Description" with "A lightweight issue tracking app."
    And I press "Create Project"
    Then I should be on the project's show page
    And I should see "Project was successfully created."
    And I should see "Lira"

  Scenario: Fail to create project with missing fields
    Given I am a logged in user
    And I am on the new project page
    When I press "Create Project"
    Then I should see "Name can't be blank"
    And I should see "Key can't be blank"

  Scenario: Fail to create project with duplicate key
    Given I am a logged in user
    And an existing project with name "Lira" already exists
    And I am on the new project page
    When I fill in "Name" with "Lira"
    And I press "Create Project"
    Then I should see "Name has already been taken"
