Feature: Log in to an account
	As a returning user
	I want to login to my account with my credentials
	So I can access my saved projects

	Scenario: User logs into their account
		Given I am a logged out user
		And I am on the login page
		And I input "zr2197@nyu.edu" "SecurePassword"
		And I click "Log in"
		Then I should be on the home page signed in

	Scenario: User logs in with invalid email
		Given I am a logged out user
		And I am on the login page
		And I input "invalidemail" "validpasswordig"
		And I click "Log in"
		Then I should be on the login page
		And I should see "Invalid email"

	Scenario: User logs in with wrong credentials
		Given I am a logged out user
		And I am on the login page
		And I input "zr2197@nyu.edu" "wrongPasswordHere"
		And I click "Log in"
		Then I should be on the login page
		And I should see "Invalid email/password"
