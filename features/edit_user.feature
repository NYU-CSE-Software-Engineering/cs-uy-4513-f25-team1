Feature: Log in to an account
	As a returning user
	I want to edit my account info
	So I can update my info

	Scenario: User logs in and edits with correct info
		When I make an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijkdefg"
		And I log into an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijkdefg"
		And I edit my account with email, username, password: "b@b.com" "longpassword" "longpassword"
		And I log out
		And I log into an account with email, username, password: "b@b.com" "longpassword" "longpassword"
		Then I should be on the projects page

	Scenario: User edits info and tries to log in with old info
		When I make an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijk"
		And I log into an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijk"
		And I edit my account with email, username, password: "b@b.com" "longpassword" "longpassword"
		And I log out
		And I log into an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijk"
		Then I should be on the login page

	Scenario: User logs in and edits with incorrect info
		When I make an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijk"
		And I log into an account with email, username, password: "a@b.com" "abcdefghijk" "abcdefghijk"
		And I edit my account with email, username, password: "dadwadwa" "abcdefghijk" "abcdefghijk"
		Then I should be on the edit page
