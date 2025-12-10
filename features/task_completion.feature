Feature: Task Completion
  As a project team member
  I want to mark tasks as completed
  So that completed work is tracked and protected from changes

  Background:
    Given I am logged in as a manager on project "Alpha"

  Scenario: Completing a task sets the completed_at timestamp
    Given a task "Task to complete" exists on project "Alpha" with:
      | description | This task will be completed |
      | status      | in_progress                 |
    When I visit the project "Alpha" page
    And I click on the task "Task to complete"
    And I click "Edit Task"
    And I select "Completed" from "Task Status"
    And I click "Update Task"
    Then I should see "Task updated."
    When I click "Back to Task"
    Then I should see "Completed At:"

  Scenario: Completed task shows completion notice
    Given a completed task "Already done" exists on project "Alpha" with:
      | description | This task was already completed |
    When I visit the project "Alpha" page
    And I click on the task "Already done"
    Then I should see "This task was completed on"
    And I should see "and cannot be modified"

  Scenario: Completed task hides edit button on show page
    Given a completed task "No edit button" exists on project "Alpha" with:
      | description | Completed tasks have no edit button |
    When I visit the project "Alpha" page
    And I click on the task "No edit button"
    Then I should not see "Edit Task"
    And I should see "Back to Project"

  Scenario: Completed task edit page shows warning and no form
    Given a completed task "Locked task" exists on project "Alpha" with:
      | description | This task is locked |
    When I visit the edit task page for "Locked task" on project "Alpha"
    Then I should see "This task was completed on"
    And I should see "and cannot be modified"
    And I should see "Back to Task"

  Scenario: Completed task cannot be modified via update
    Given a completed task "Immutable task" exists on project "Alpha" with:
      | description | This task should not change |
    When I try to update task "Immutable task" with title "Changed title"
    Then the task "Immutable task" should still have title "Immutable task"

  Scenario: Filter by completed status shows only completed tasks
    Given a task "Active task" exists on project "Alpha" with:
      | description | This is an active task |
      | status      | in_progress            |
    And a completed task "Done task" exists on project "Alpha" with:
      | description | This is a done task |
    When I visit the project "Alpha" page
    And I filter by status "Completed"
    Then I should see "Done task" within the task list
    And I should not see "Active task" within the task list
