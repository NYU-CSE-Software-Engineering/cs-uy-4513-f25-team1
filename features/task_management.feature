Feature: Task Management
  As a project team member
  I want to manage tasks with detailed information
  So that the team can effectively track and organize work

  Background:
    Given I am logged in as a manager on project "Alpha"

  Scenario: Create a task with all fields
    When I click "New Task"
    And I fill in "Title" with "Implement authentication"
    And I fill in "Description" with "Add user login and registration functionality"
    And I select "Feature" from "Type"
    And I fill in "Branch Link (optional)" with "https://github.com/org/repo/tree/feature-auth"
    And I select "High" from "Priority (optional)"
    And I fill in the due date field with tomorrow's date
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "Implement authentication"
    And I should see "Add user login and registration functionality"
    And I should see "Feature"
    And I should see "High"

  Scenario: Task creation fails without description
    When I click "New Task"
    And I fill in "Title" with "Missing description task"
    And I leave "Description" blank
    And I click "Create Task"
    Then I should see "Description can't be blank"

  Scenario: Task without assignee defaults to Todo status
    When I click "New Task"
    And I fill in "Title" with "Unassigned task"
    And I fill in "Description" with "This task has no assignee"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "Todo"

  Scenario: Task with assignee defaults to In Progress status
    Given a developer "dev_user" exists on project "Alpha"
    When I click "New Task"
    And I fill in "Title" with "Assigned task"
    And I fill in "Description" with "This task is assigned to a developer"
    And I select "dev_user" from "Assignee (optional)"
    And I click "Create Task"
    Then I should see "Task was successfully created."
    And I should see "In Progress"

  Scenario: Assignee dropdown excludes managers
    Given a manager "other_manager" exists on project "Alpha"
    Given a developer "dev_user" exists on project "Alpha"
    When I click "New Task"
    Then I should see "dev_user" in the assignee dropdown
    And I should not see "other_manager" in the assignee dropdown

  Scenario: View task shows all details
    Given a task "Review PR" exists on project "Alpha" with:
      | description  | Review the pull request for feature branch |
      | type         | Feature                                    |
      | branch_link  | https://github.com/org/repo/pull/123       |
      | priority     | medium                                     |
      | status       | in_progress                                |
    When I visit the project "Alpha" page
    And I click on the task "Review PR"
    Then I should see "Review PR"
    And I should see "Review the pull request for feature branch"
    And I should see "Feature"
    And I should see "Medium"
    And I should see "In Progress"
    And I should see "https://github.com/org/repo/pull/123"

  Scenario: Edit task updates all fields
    Given a task "Old Title" exists on project "Alpha" with:
      | description | Old description |
      | priority    | low             |
    When I visit the project "Alpha" page
    And I click on the task "Old Title"
    And I click "Edit Task"
    And I fill in "Title" with "Updated Title"
    And I fill in "Description" with "Updated description"
    And I select "High" from "Priority (optional)"
    And I click "Update Task"
    Then I should see "Task updated."
    When I click "View Task"
    Then I should see "Updated Title"
    And I should see "Updated description"
    And I should see "High"
