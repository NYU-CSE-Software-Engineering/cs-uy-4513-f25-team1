Feature: Enforce WIP limit on In Progress
  As a project manager
  I want to prevent adding more than 2 tasks to "In Progress"
  So that the team doesn't exceed the WIP limit

  Background:
    Given a project named "Alpha" exists with WIP limit 2
    And there are already 2 tasks in status "In Progress"
    And I should see a task titled "Pre-existing Task 3" in status "To Do"
    And I am on the "Alpha" project board

  Scenario: Block adding a task when WIP limit reached
    When I move "Pre-existing Task 3" to "In Progress"
    Then I should see "WIP limit" limit 2 reached for "In Progress"
    And "Pre-existing Task 3" should remain in "To Do"

