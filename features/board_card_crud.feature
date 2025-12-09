Feature: Card CRUD on a board
  As a project member
  I want to create, edit, and delete cards in board columns
  So I can track work items

  Background:
    Given I am a logged in user
    And I am a Project Member (not admin) of "My Project"
    And the project has a board with columns:
      | To Do       |
      | In Progress |
      | Done        |

  Scenario: Create a card in a column
    When I create a card in "To Do" with:
      | Title       | New task |
      | Description | Details  |
    Then I should see a card titled "New task" in "To Do"

  Scenario: Edit a card
    Given a card titled "Bug" exists in "In Progress"
    When I rename the card "Bug" to "Critical bug"
    Then I should see a card titled "Critical bug" in "In Progress"
    And I should not see a card titled "Bug" in "In Progress"

  Scenario: Delete a card
    Given a card titled "Chore" exists in "Done"
    When I delete the card titled "Chore"
    Then I should not see a card titled "Chore" in "Done"

  Scenario: Fail to create a card without title
    When I create a card in "To Do" with:
      | Title       |         |
      | Description | None    |
    Then I should see "Title can't be blank"


