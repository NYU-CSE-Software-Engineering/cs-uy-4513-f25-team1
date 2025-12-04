Feature: Log in to an account
	As a returning user
	I want to login to my account with my credentials
	So I can access my saved projects

	Scenario: User logs into their account
		Given I am a logged out user
		And I am on the login page
		When I input valid email and password
		And I click "Sign in"
		Then I should be on the home page signed in

	Scenario: User logs in with invalid email
		Given I am a logged out user
		And I am on the login page
		When I input invalid email and password
		And I click "Sign in"
		Then I should be on the login page
		And I should see "Try another email address or password"

	Scenario: User logs in with wrong credentials
		Given I am a logged out user
		And I am on the login page
		When I input wrong password with email
		And I click "Sign in"
		Then I should be on the login page
		And I should see "Try another email address or password"
