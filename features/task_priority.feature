Feature: Task Priority
  As a project member
  I want to set priorities for tasks
  So that the team knows what to work on first

  Background:
    Given a project named "Beta" exists
    And I am on the "Beta" project's tasks page

  Scenario: Create a task with High priority
    When I click "New Task"
    And I fill in "Title" with "Urgent Bug Fix"
    And I select "High" from "Priority"
    And I click "Create Task"
    Then I should see "Urgent Bug Fix"
    And I should see "High" within the task details

  Scenario: Change task priority
    Given a task titled "Low Priority Task" exists in project "Beta" with priority "Low"
    When I edit the task "Low Priority Task"
    And I select "Urgent" from "Priority"
    And I click "Update Task"
    Then I should see "Urgent" within the task details
