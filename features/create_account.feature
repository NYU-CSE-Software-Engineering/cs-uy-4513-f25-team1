Feature:Create an account
	As a new user to Jira-lite
	I want to create an account
	So that I can access all the features of Jira-lite

	Scenario: User creates an account with valid inputs 
		Given I am a logged out user
		And I am on the page login/create
		And I input "zr2197@nyu.edu" "user" "securepassword" "securepassword"
		And I click "Create Account"
		Then I should be on the page login/signin

	Scenario: User creates an account with invalid email
		Given I am a logged out user
		And I am on the page login/create
		And I input "invalidEmail" "user" "securepassword" "securepassword"
		And I click "Create Account"
		Then I should be on the page login/create
		And I should see "Invalid email" 
	
	Scenario: User creates an account with taken email
		Given I am a logged out user
		And I am on the page login/create
		And "zr2197@nyu.edu" is in the Users table
		And I input "zr2197@nyu.edu" "user" "securepassword" "securepassword"
		Then I should be on the page login/create
		And I should see "Email already taken"
	
	Scenario: User creates an account with an insecure password
		Given I am a logged out user
		And I am on the page login/create
		And I input "zr2197@nyu.edu" "user" "unsafe" "unsafe"
		Then I should be on the page login/create
		And I should see "Password needs to be at least 8 characters"
	
	Scenario: User creates an account with the wrong repeated password
		Given I am a logged out user
		And I am on the page login/create
		And I input "zr2197@nyu.edu" "user" "securePassword" "differentPassword"
		Then I should be on the page login/create
		And I should see "Password does not match"
