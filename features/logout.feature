@wip
Feature:Log out of an account
	As a logged-in user 
	I want to log out of my account 
	So that I can secure my account when I'm done working.

	Scenario: User logs out 
		Given I am a logged in user
		When I click "Log out"
		Then I should be on the home page
		And I should see "Signed out successfully"
	
	Scenario: User logs out and tries to return to their projects page
		Given I am a logged in user
		When I click "Log out"
		And I go to my projects page
		Then I should see an error page

