Feature: Board column management
  As a project admin
  I want to manage board columns
  So I can tailor workflow stages

  Background:
    Given I am a logged in user
    And I am a Project Admin of "My Project"
    And the project has a board with columns:
      | To Do       |
      | In Progress |
      | Done        |

  Scenario: Add a new column
    When I add a column named "Review"
    Then I should see "Review" in the board columns

  Scenario: Rename a column
    When I rename the column "To Do" to "Backlog"
    Then I should see "Backlog" in the board columns
    And I should not see "To Do" in the board columns

  Scenario: Delete a column
    When I delete the column "Done"
    Then I should not see "Done" in the board columns

  Scenario: Reorder columns using controls
    When I move column "In Progress" up
    Then the column order should be:
      | In Progress |
      | To Do       |
      | Done        |

  Scenario: Non-admin cannot modify columns
    Given I am a Project Member (not admin) of "My Project"
    When I try to add a column named "QA"
    Then I should see "You do not have permission to modify columns"


