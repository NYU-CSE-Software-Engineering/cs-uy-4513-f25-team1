Feature: Log in to an account
	As a returning user
	I want to edit my account info
	So I can update my info

	Scenario: User logs in and edits with correct info
		When I make an account with email, username, password: "a@b.com" "abc" "abc"
		And I log into an account with email, username, password: "a@b.com" "abc" "abc"
		And I edit my account with email, username, password: "b@b.com" "bbc" "bbc"
		And I log out
		And I log into an account with email, username, password: "b@b.com" "bbc" "bbc"
		Then I should be on the projects page

	Scenario: User edits info and tries to log in with old info
		When I make an account with email, username, password: "a@b.com" "abc" "abc"
		And I log into an account with email, username, password: "a@b.com" "abc" "abc"
		And I edit my account with email, username, password: "b@b.com" "bbc" "bbc"
		And I log out
		And I log into an account with email, username, password: "a@b.com" "abc" "abc"
		Then I should be on the login page

	Scenario: User logs in and edits with incorrect info
		When I make an account with email, username, password: "a@b.com" "abc" "abc"
		And I log into an account with email, username, password: "a@b.com" "abc" "abc"
		And I edit my account with email, username, password: "dadwadwa" "abc" "abc"
		Then I should be on the edit page
