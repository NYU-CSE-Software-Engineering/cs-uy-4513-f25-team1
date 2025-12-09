Feature: Filter tasks
  As a signed in user
  I want to filter tasks by their types
  So that I can view relevant tasks

  Background:
    Given I am a logged in user
    And a project named "Test" exists with sample tasks

  Scenario: Default view shows tasks sorted by date created
    Given I am on the Projects page
    And I click the "Test" project
    Then I should see tasks filtered by date created

  Scenario: Filter tasks by Feature type
    Given I am on the Projects page
    And I click the "Test" project
    When I click "Feature" in the filter select
    And I click the "Apply filters" button
    Then I should only see tasks with type "Feature"

  Scenario: Filter tasks by Backlog type
    Given I am on the Projects page
    And I click the "Test" project
    When I click "Backlog" in the filter select
    And I click the "Apply filters" button
    Then I should only see tasks with type "Backlog"

  Scenario: Filter tasks by Bug type
    Given I am on the Projects page
    And I click the "Test" project
    When I click "Bug" in the filter select
    And I click the "Apply filters" button
    Then I should only see tasks with type "Bug"

  Scenario: Sort tasks by date modified
    Given I am on the Projects page
    And I click the "Test" project
    When I click "Date Modified" in the filter select
    And I click the "Apply filters" button
    Then I should see tasks filtered by date modified

  Scenario: Invalid filter parameter defaults to date created
    Given I am on the Projects page
    And I click the "Test" project
    And I add "?filter=blah" to the path and press enter
    Then I should see tasks filtered by date created
