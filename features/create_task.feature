Feature: Create task
  As a project manager
  I want to create a task under a project
  So that the team can track work

  Background:
    Given I am logged in as a manager on project "Alpha"

  Scenario: Create a task with valid inputs
    When I click the add task button
    And I fill in "Title" with "Implement WIP limit"
    And I fill in "Description" with "Add work-in-progress limits to the board"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "Implement WIP limit"
    And I should see "Add work-in-progress limits to the board"

  Scenario: Task creation fails without title
    When I click the add task button
    And I leave "Title" blank
    And I fill in "Description" with "Some description"
    And I click "Create Task"
    Then I should see "Title can't be blank"

  Scenario: Task creation fails without description
    When I click the add task button
    And I fill in "Title" with "Missing description"
    And I leave "Description" blank
    And I click "Create Task"
    Then I should see "Description can't be blank"
