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
A login/create view with a form that takes in an email, username, password, and repeated password. View will update to show error message if there was any error filling out the form.

## Controller
An accountCreate controller with the following functions:
* valid_email
* email_not_taken
* valid_username
* valid_password
* valid_repeated_password
