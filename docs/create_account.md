# User Story
**As a** new user to Jira-lite
**I want to** create an account
**So that I can** access all the features of Jira-lite.

## Acceptance Criteria
* Email is a valid email
* Email is not taken
* Username contains valid characters
* Password is at least 8 characters long
* Repeated password is the same as inputted password
* Error messages follow good security principles (reveal as little information as possible)

# Task 3: Model-View-Controller

## Model
An identity model with the users table. Emails will be the primary key stored as a string, username:string, password:string but password's hash is stored, not its plaintext.

## View
A login/create view with a form that takes in an email, username, password, and repeated password. View will update to show error message if there was any error filling out the form and have empty form fields. On success, we redirect to login/signin.html.erb

## Controller
An accountCreate controller with the following functions:
new: Displays the form login/create
create: Handles form submission. Verfies email address, password specifications, and repeated password is actually repeated.
redirect: Redirects back to login/create with an error message on fail. Else, redirects to login/signin.html.erb
