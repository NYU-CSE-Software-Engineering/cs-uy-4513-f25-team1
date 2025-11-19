Feature: Create task
  As a project member
  I want to create a task under a project
  So that the team can track work

  Background:
    Given a project named "Alpha" exists
    And I am on the "Alpha" project's tasks page

  Scenario: Create a task with valid inputs
    When I click "New Task"
    And I fill in "Title" with "Implement WIP limit"
    And I select "Todo" from "Status"
    And I click "Create Task"
    Then I should see "Implement WIP limit"
    And I should see the task in the list for project "Alpha"

  Scenario: Task creation fails without title
    When I click "New Task"
    And I leave "Title" blank
    And I click "Create Task"
    Then I should see "Title can't be blank"

