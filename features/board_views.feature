Feature: Board views
  As a project member
  I want to see status columns with WIP counts and filters
  So I can understand workflow at a glance

  Background:
    Given I am a logged in user
    And a project exists with:
      | name | BoardProj |
    And issues exist:
      | title   | issue_type | status       |
      | Bug A   | bug        | not started  |
      | Task B  | task       | in progress  |
      | Sub C   | subtask    | done         |
      | Task D  | task       | in progress  |

  Scenario: Show WIP counts by status column
    When I visit the board page for the project
    Then I should see a column "not started" with count 1
    And I should see a column "in progress" with count 2
    And I should see a column "done" with count 1

  Scenario: Filter by issue type
    When I apply the board filter for issue types "task"
    Then I should see a column "in progress" with count 2
    And I should not see a card of type "bug"

  Scenario: Over WIP limit indication
    Given project settings set WIP limit for "in progress" to 1
    When I visit the board page for the project
    Then the column "in progress" should indicate over WIP


