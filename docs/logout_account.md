# User Story
As a logged-in user, I want to log out of my account so that I can secure my account when I'm done working.

# Acceptance Criteria- When I click the "Logout" button, I am redirected to the login page.
- I see the message "Signed out successfully."
- My session is terminated so I can’t access protected pages anymore.
- The logout button is visible only when I’m logged in.

# Task 3: Model-View-Controller

## Model
An identity model with the users table. Emails will be the primary key stored as a string, username:string, password:string but password's hash is stored, not its plaintext.

## View
Add a "Logout" button/link in the navigation bar that triggers the logout route.

## Controller
A `SessionsController` with a `destroy` action that ends the session and redirects to the login page with a success notice.

