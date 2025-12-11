Feature:Create an account
    As a new user to Jira-lite
    I want to create an account
    So that I can access all the features of Jira-lite

    Scenario: User creates an account with valid inputs 
        Given I am a logged out user
        And I am on the register page
	When I type for email username password repeat-password "testing@gmail.com" "testingUser" "password" "password"
        And I click "Create Account"
        Then I should be on the projects page

    Scenario: User creates an account with invalid email
        Given I am a logged out user
        And I am on the register page
	When I type for email username password repeat-password "invalid" "testingUser" "password" "password"
        And I click "Create Account"
        Then I should be on the same register page
    
    Scenario: User creates an account with taken email
        Given I am a logged out user
        And I am on the register page
        When I input a taken email with other valid fields
        And I click "Create Account"
        Then I should be on the same register page
    
    Scenario: User creates an account with invalid password
        Given I am a logged out user
        And I am on the register page
	When I type for email username password repeat-password "testing@gmail.com" "testingUser" "pass" "pass"
        And I click "Create Account"
        Then I should be on the same register page
    
    Scenario: User creates an account with invalid repeated_password
        Given I am a logged out user
        And I am on the register page
	When I type for email username password repeat-password "testing@gmail.com" "testingUser" "password" "wrongpassword"
        And I click "Create Account"
        Then I should be on the same register page
