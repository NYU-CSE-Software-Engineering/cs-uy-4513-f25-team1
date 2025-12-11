Feature: Task Authorization
  As a project collaborator
  I want role-based access control for tasks
  So that only authorized users can perform certain actions

  Scenario: Manager can create a new task
    Given I am logged in as a manager on project "Alpha"
    When I visit the project "Alpha" page
    Then I should see "New Task"
    When I click "New Task"
    Then I should be on the new task page for project "Alpha"

  Scenario: Developer cannot create a new task
    Given I am logged in as a developer on project "Alpha"
    When I visit the project "Alpha" page
    Then I should not see "New Task"

  Scenario: Developer cannot access new task page directly
    Given I am logged in as a developer on project "Alpha"
    When I visit the new task page for project "Alpha"
    Then I should see "Only managers can create tasks."
    And I should be on the project "Alpha" page

  Scenario: Developer can view a task
    Given I am logged in as a developer on project "Alpha"
    And a task "Dev viewable task" exists on project "Alpha" with:
      | description | A task for developers to view |
    When I visit the project "Alpha" page
    And I click on the task "Dev viewable task"
    Then I should see "Dev viewable task"
    And I should see "A task for developers to view"

  Scenario: Developer can edit a task
    Given I am logged in as a developer on project "Alpha"
    And a task "Dev editable task" exists on project "Alpha" with:
      | description | A task for developers to edit |
    When I visit the project "Alpha" page
    And I click on the task "Dev editable task"
    And I click "Edit Task"
    Then I should be on the edit task page for "Dev editable task"
    When I fill in "Title" with "Developer updated task"
    And I click "Update Task"
    Then I should see "Task updated."

  Scenario: Invited user cannot view task details
    Given I am logged in as an invited user on project "Alpha"
    And a task "Restricted task" exists on project "Alpha" with:
      | description | An invited user should not see this |
    When I visit the task page for "Restricted task" on project "Alpha"
    Then I should see "You do not have permission to edit this project."
    And I should be on the project "Alpha" page

  Scenario: Invited user cannot edit tasks
    Given I am logged in as an invited user on project "Alpha"
    And a task "Restricted edit task" exists on project "Alpha" with:
      | description | An invited user should not edit this |
    When I visit the edit task page for "Restricted edit task" on project "Alpha"
    Then I should see "You do not have permission to edit this project."
    And I should be on the project "Alpha" page

  Scenario: Manager can edit any task
    Given I am logged in as a manager on project "Alpha"
    And a task "Manager editable task" exists on project "Alpha" with:
      | description | A task managers can edit |
    When I visit the project "Alpha" page
    And I click on the task "Manager editable task"
    And I click "Edit Task"
    And I fill in "Title" with "Manager updated this"
    And I click "Update Task"
    Then I should see "Task updated."
    When I click "View Task"
    Then I should see "Manager updated this"
