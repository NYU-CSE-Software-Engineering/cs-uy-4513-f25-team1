Feature: Project creation with default board
  As a signed-in user
  I want to create a project that comes with a default board
  So I can start organizing work immediately

  Background:
    Given I am a signed-in user

  Scenario: Create a project with a valid name
    When I go to the new project page
    And I fill in "Name" with "My Project"
    And I press "Create Project"
    Then I should see "Project created"
    And I should see "Main Board"
    And I should see the board columns:
      | To Do       |
      | In Progress |
      | Done        |

  Scenario: Fail to create a project with a blank name
    When I go to the new project page
    And I press "Create Project"
    Then I should see "Name can't be blank"


