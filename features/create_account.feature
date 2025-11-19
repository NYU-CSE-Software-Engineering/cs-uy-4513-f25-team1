Feature:Create an account
    As a new user to Jira-lite
    I want to create an account
    So that I can access all the features of Jira-lite

    Scenario: User creates an account with valid inputs 
        Given I am a logged out user
        And I am on the page login/create
        When I input valid inputs for fields email username password repeated_password
        And I click "Create Account"
        Then I should be on the home page signed in
        And my account should be in the Users table

    Scenario: User creates an account with invalid email
        Given I am a logged out user
        And I am on the page login/create
        When I input an invalid email with other valid fields
        And I click "Create Account"
        Then I should be on the page login/create
        And I should see "Email is invalid" 
    
    Scenario: User creates an account with taken email
        Given I am a logged out user
        And I am on the page login/create
        When I input a taken email with other valid fields
        And I click "Create Account"
        Then I should be on the page login/create
        And I should see "Email has already been taken"
    
    Scenario: User creates an account with invalid password
        Given I am a logged out user
        And I am on the page login/create
        When I input an invalid password with other valid fields
        And I click "Create Account"
        Then I should be on the page login/create
        And I should see "Password is too short (minimum is 6 characters)"
    
    Scenario: User creates an account with invalid repeated_password
        Given I am a logged out user
        And I am on the page login/create
        When I input an invalid repeated_password with other valid fields
        And I click "Create Account"
        Then I should be on the page login/create
        And I should see "Password confirmation doesn't match Password"
