Feature: filter
    As a signed in user
    I want to filter tasks by their types
    So that I can view relevant tasks

    Scenario:
        Given I am a signed in user
        And I am on the Projects page
        Then I should see tasks filtered by date created

    Scenario:
        Given I am a signed in user
        And I am on the Projects page
        When I click "Feature" in the filter select
        And I click the "Apply filters" button
        Then I should only see tasks with type "Feature"

    Scenario:
        Given I am a signed in user
        And I am on the Projects page
        When I click "Feature" in the filter select
        And I click the "Apply filters" button
        Then I should only see tasks with type "Backlog"

    Scenario:
        Given I am a signed in user
        And I am on the Projects page
        When I click "Bug" in the filter select
        And I click the "Apply filters" button
        Then I should only see tasks with type "Bug"

    Scenario:
        Given I am a signed in user
        And I am on the Projects page
        When I click "Date Modified" in the filter select
        And I click the "Apply filters" button
        Then I should see tasks filtered by date modified

    Scenario:
        Given I am a signed in user
        And I am on the Projects page
        When I add "?filter=blah" to the path and press enter
        Then I should see tasks filtered by date created
