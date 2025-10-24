Feature:Create an account
    As a new user to Jira-lite
    I want to create an account
    So that I can access all the features of Jira-lite

    Scenario: User creates an account with valid inputs 
        Given I am a logged out user
        And I am on the page login/create
        When I input valid inputs for fields email username password repeated_password
        And I click "Create Account"
        Then I should be on the page login/signin
        And my account should be in the Users table

    Scenario: User creates an account with invalid email
        Given I am a logged out user
        And I am on the page login/create
        When I input an invalid email
        And I input valid inputs for fields username password repeated_password
        And I click "Create Account"
        Then I should be on the page login/create
        And I should see "Invalid email" 
    
    Scenario: User creates an account with taken email
        Given I am a logged out user
        And I am on the page login/create
        When I input a taken email
        And I input valid inputs for fields username password repeated_password
        Then I should be on the page login/create
        And I should see "Email already taken"
    
    Scenario: User creates an account with invalid password
        Given I am a logged out user
        And I am on the page login/create
        When I input an invalid password
        And I input valid inputs for fields email username repeated_password
        Then I should be on the page login/create
        And I should see "Password must be at least 8 characters"
    
    Scenario: User creates an account with invalid repeated_password
        Given I am a logged out user
        And I am on the page login/create
        When I input an invalid repeated_password
        And I input valid inputs for fields email username password
        Then I should be on the page login/create
        And I should see "Passwords must match"
