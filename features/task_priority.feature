Feature: Task Priority
  As a project manager
  I want to set task priorities
  So that the team knows which tasks are most important

  Background:
    Given I am logged in as a manager on project "Alpha"

  Scenario: Create task with Low priority
    When I click the add task button
    And I fill in "Title" with "Low priority task"
    And I fill in "Description" with "This is a low priority item"
    And I select "Low" from "Priority (optional)"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "Low"

  Scenario: Create task with Medium priority
    When I click the add task button
    And I fill in "Title" with "Medium priority task"
    And I fill in "Description" with "This is a medium priority item"
    And I select "Medium" from "Priority (optional)"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "Medium"

  Scenario: Create task with High priority
    When I click the add task button
    And I fill in "Title" with "High priority task"
    And I fill in "Description" with "This is a high priority item"
    And I select "High" from "Priority (optional)"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "High"

  Scenario: Create task with Urgent priority
    When I click the add task button
    And I fill in "Title" with "Urgent priority task"
    And I fill in "Description" with "This is an urgent item"
    And I select "Urgent" from "Priority (optional)"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "Urgent"

  Scenario: Create task with No Priority
    When I click the add task button
    And I fill in "Title" with "No priority task"
    And I fill in "Description" with "This has no priority set"
    And I select "No Priority" from "Priority (optional)"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "No Priority"

  Scenario: Priority displays on project page task list
    Given a task "Priority visible task" exists on project "Alpha" with:
      | description | Shows priority on list |
      | priority    | high                   |
    When I visit the project "Alpha" page
    Then I should see "Priority visible task"
    And I should see "High" within the task list

  Scenario: Update task priority via API
    Given a task "Change priority" exists on project "Alpha" with:
      | description | Priority will change |
      | priority    | low                  |
    When I update task "Change priority" with priority "urgent"
    Then I should see "Task updated."
    And I should see "Urgent"

  Scenario: Task show page displays priority
    Given a task "Show priority" exists on project "Alpha" with:
      | description | Priority shown on details |
      | priority    | medium                    |
    When I visit the project "Alpha" page
    And I click on the task "Show priority"
    Then I should see "Priority:"
    And I should see "Medium"
