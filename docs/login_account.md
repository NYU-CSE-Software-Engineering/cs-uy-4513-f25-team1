# User Story
**As a** returning user
**I want to** login to my account with my credentials
**So I can** access my saved projects

## Acceptance Criteria
* Inputted email address is an email
* Email and password match
* Error messages reveal as little information as possible

# Task 3: Model-View-Controller

## Model
An identity model with the users table. Emails will be the primary key stored as a string, username:string, password:string but password's hash is stored, not its plaintext.

## View 
A login/signin.html.erb view with a form that takes in an email and a password. On submission, it will either log in the user or show an appropriate error message.

## Controller
An accountSignin controller with the following actions:
new: Displays the login form login/signin.html.erb
create: Handles form submission. Verifies email address, matching of email and password, and shows respective error messages.
redirect: on error, redirect back to login/signin.html.erb with empty fields and corresponding error message. On success, go to home page while logged in.
