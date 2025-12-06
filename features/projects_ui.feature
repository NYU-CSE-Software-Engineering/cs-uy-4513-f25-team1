Feature: Projects UI
  As a signed-in user
  I want to create and configure projects
  So I can manage work on boards

  Background:
    Given I am a signed-in user

  Scenario: Create a project successfully
    When I go to the projects page
    And I click the new project button
    And I fill in the project form with:
      | Name        | Alpha        |
      | Key         | ALP          |
      | Description | Alpha proj   |
    And I submit the create project form
    Then I should see a notice "Project created"
    And I should be on the project page
    And I should see the status columns:
      | not started |
      | in progress |
      | done        |
      | cancelled   |

  Scenario: Fail to create a project without name
    When I go to the projects page
    And I click the new project button
    And I submit the create project form
    Then I should see an alert "Name can't be blank"


