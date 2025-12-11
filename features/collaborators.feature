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
      | name         | wip_limit |
      | Test Project | 5         |
    And "manager" is a manager on project "Test Project"
    And "dev1" is a developer on project "Test Project"
    And I am signed in as "manager"

  Scenario: Manager views all collaborators on project page
    When I visit the project "Test Project" page
    Then I should see "Collaborators:"
    And I should see "manager" in the collaborators carousel
    And I should see "dev1" in the collaborators carousel

  Scenario: Manager views individual collaborator details
    Given "dev1" has 3 completed tasks on project "Test Project"
    When I visit the project "Test Project" page
    And I click on collaborator "dev1" in the carousel
    Then I should see "dev1"
    And I should see "Performance Metrics"
    And I should see "Total Assigned"
    And I should see "Total Completed"

  Scenario: Manager changes a developer's role to manager
    When I visit the profile page for "dev1" on project "Test Project"
    And I click the edit collaborator button
    Then I should see "Change Role"
    And I should see "Manager"
    And I should see "Developer"

  Scenario: Manager can access collaborator removal page
    When I visit the profile page for "dev1" on project "Test Project"
    And I click the edit collaborator button
    Then I should see "Remove Collaborator"
    And I should see "Remove dev1 from Project"

  Scenario: Developer can view collaborators on project page
    Given I am signed in as "dev1"
    When I visit the project "Test Project" page
    Then I should see "Collaborators:"
    And I should see "manager" in the collaborators carousel
    And I should see "dev1" in the collaborators carousel

  Scenario: Developer can edit their own profile
    Given I am signed in as "dev1"
    When I visit the project "Test Project" page
    And I click on collaborator "dev1" in the carousel
    Then I should see the edit collaborator button
    When I click the edit collaborator button
    Then I should see "Leave Project"

  Scenario: Collaborators summary shows on project page
    When I visit the project "Test Project" page
    Then I should see "Collaborators:"
    And I should see "manager"
    And I should see "dev1"

  Scenario: Completion rate is displayed for collaborator
    Given "dev1" has 5 completed tasks on project "Test Project"
    When I visit the project "Test Project" page
    Then I should see "100.0%" for collaborator "dev1" in the carousel

  Scenario: Manager views task metrics for a collaborator
    Given "dev1" has the following tasks on project "Test Project":
      | title       | status      |
      | Task 1      | Completed   |
      | Task 2      | In Progress |
      | Task 3      | In Review   |
    When I visit the profile page for "dev1" on project "Test Project"
    Then I should see "Total Assigned"
    And I should see "Total Completed"
    And I should see "Current WIP"
    And I should see "Completion Rate"
