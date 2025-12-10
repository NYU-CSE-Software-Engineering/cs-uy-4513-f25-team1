Feature: Collaborator Management
  As a project manager
  I want to manage collaborators on my project
  So that I can control who has access and what roles they have

  Background:
    Given the following users exist:
      | username | email              | password |
      | manager  | manager@test.com   | password |
      | dev1     | dev1@test.com      | password |
      | dev2     | dev2@test.com      | password |
    And the following project exists:
      | name         | description      |
      | Test Project | Test Description |
    And "manager" is a manager on project "Test Project"
    And "dev1" is a developer on project "Test Project"
    And I am signed in as "manager"

  Scenario: Manager views all collaborators
    When I visit the project "Test Project" page
    And I click on "View All Collaborators"
    Then I should see the collaborators page
    And I should see "manager" in the managers section
    And I should see "dev1" in the developers section

  Scenario: Manager views individual collaborator details
    Given "dev1" has 3 completed tasks on project "Test Project"
    When I visit the collaborators page for project "Test Project"
    And I click on "dev1"
    Then I should see "dev1's Profile"
    And I should see "Contribution Statistics"
    And I should see "Total Tasks"
    And I should see "Completed Tasks: 3"

  Scenario: Manager changes a developer's role to manager
    When I visit the collaborators page for project "Test Project"
    And I click on "Edit" for collaborator "dev1"
    Then I should see "Change Role"
    And I should see "Manager"
    And I should see "Developer"

  Scenario: Manager can access collaborator removal page
    When I visit the collaborators page for project "Test Project"
    And I click on "Edit" for collaborator "dev1"
    Then I should see "Remove Collaborator"
    And I should see "Remove dev1 from Project"

  Scenario: Developer views collaborators but cannot edit others
    Given I am signed in as "dev1"
    When I visit the collaborators page for project "Test Project"
    Then I should see "manager" in the managers section
    And I should see "dev1" in the developers section
    And I should not see an "Edit" link for "manager"

  Scenario: Developer can edit their own profile
    Given I am signed in as "dev1"
    When I visit the collaborators page for project "Test Project"
    And I click on "dev1"
    Then I should see "Edit Collaborator"
    When I click "Edit Collaborator"
    Then I should see "Leave Project"

  Scenario: Collaborators summary shows on project page
    When I visit the project "Test Project" page
    Then I should see "Collaborators (2)"
    And I should see collaborator badges
    And I should see "View All Collaborators" link

  Scenario: Contribution percentage is calculated correctly
    Given "dev1" has 5 completed tasks on project "Test Project"
    And the project "Test Project" has 5 additional tasks from other users
    When I visit the collaborators page for project "Test Project"
    Then I should see "Contribution: 50.0%" for "dev1"

  Scenario: Manager views tasks by status for a collaborator
    Given "dev1" has the following tasks on project "Test Project":
      | title       | status      |
      | Task 1      | Completed   |
      | Task 2      | In Progress |
      | Task 3      | In Review   |
    When I visit the profile page for "dev1" on project "Test Project"
    Then I should see "In Progress (1)"
    And I should see "In Review (1)"
    And I should see "Completed (1)"
    And I should see "Task 1" in the completed section
    And I should see "Task 2" in the in progress section
    And I should see "Task 3" in the in review section
