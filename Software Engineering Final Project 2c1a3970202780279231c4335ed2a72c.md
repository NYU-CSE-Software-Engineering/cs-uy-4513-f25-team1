# Software Engineering Final Project

## Current State:

- Basic Database scheme (to be changed as need)
- Landing Page (Inconsequential)
- Features Page (Inconsequential)
- Insufficient Testing (even for the limited features we have)
- Basic User Authentication Working (This is good)
- Project Creation ()

**Roles:**
Zesan: Forget/Reset password functionality
Perry: Create a sidebar listing projects (make it a partial) / 
Wes: Inviting other users to project / Making this Notion Doc better
Chaewon: Adding RSpec tests for task creation and filtering

Zicheng: collaborator list & edit

# A Good & Typical Ruby on Rails PR Includes

- Data Model Changes
    - A migration file if you change the db schema
    - The updated schema (after running the migration)
    - Updated seed file
        - If you change an existing data model, must update seed
        - if you add a new one, seed only required if you want it. (not required)
    - The Model Updates (Active Record)
    - Model Factory updates (for testing)
- The View Updates (.erb files)
    - Styling (Optional)
- Routes file changes (if there is new page navigation)
- The Controller Updates
- Testing (Required):
    - Cucumber Tests
    - RSpec tests
    - All new tests passing.
    - No old tests failing
    - Maintain at least 80% test coverage before submitting PR.
    
    ## EVERYONE!!! PLEASE RUN THE TESTS & APP TO VERIFY FUNCTIONALITY BEFORE SUBMITTING PR!!!
    
    ```bash
    bundle exec rails db:migrate # If you change the DB you need a migration file
    bin/rails server #running the server
    ```
    

# Pages, Endpoints, & Functionality

## / (homepage)

- This is the landing page for the website.
- There are three sections
    - Nav Bar: With a basic logo and a Login & Signup button
        - user click login, they are taken to **session/new**
        - user click signup, they are taken to **users/new**
    - If the user is logged in on the homepage, then the user will see the a button “go to app” which takes the user to **/projects**
    - Hero Section: Project Name and goofy Quote
    - Feature Section: Cards showing the different thing the app does

## /session/new (Login Page)

- This is where the user logs in.
- There will be a form where you enter your email and password
    - Email validations for format and existence ?
    - Passwords for incorrect passwords ?
- Upon successful login user is taken to **/projects**
- There will a “Forgot Password” button which takes you to **/passwords/new (rails default)**
- there will be a “Sign Up” button which takes you to **users/new**

## /users/:id/edit/password ?  (Forgot Password)

- This is the Reset Password flow
- The user will enter their email. if an email exists:
    - Take them to a password page (new endpoint?)
    - they enter the new password
    - they confirm new password

## /projects (landing page after login)

- **Sidebar on the left with 5 sections**
    - Managed Projects: A list of projects where you are of role manager
        - The header of the list will have a “+” button that takes you to /projects/new
        - each entry a clickable button which takes you to /**projects/:id (done)**
    - Developer Projects: A list of projects where you are of role developer
        - each entry a clickable button which takes you to /**projects/:id (done)**
    - Invitations: A list of invites. (might need another table for this)
        - Each entry is the name of the project and there is a check and X button where you agree to reject joining.
            - If you agree: the invite disappears and the new project pops up in your “Developer” projects
                - Your role is changed from invitee to developer in the collaborators table
            - If you reject: the invite disappears and the project does not appear in your “Developer” Projects
                - The record in the collaborators table is destroyed.
    - Settings
        - A button that navigates to the settings page. **/user/settings (done)**
    - Logout
        - A button that logs out the user and sends them back to the home screen. **(done)**
        - It will end the user’s session or whatever that entails @Zesan Rahman (pretty sure this is done?)
- The main view will have one card that says “Create Project” with a little + and folder icon which directs the user to **/projects/new (has create project but doesn’t have + or icon)**

## /projects/new

- this is the page where a user will create a project.
- They will enter the name of the project.
- They will enter the description of a project.
- They can enter an optional github repo link.
- And they will invite initial developers to the project.
    - Manager enters an email or username and clicks the + button
        - This will create an invite for the user in their invites column see
- They can click the **create** button which will take them to **/projects/:id** (The new project they created)
    - When they click the create button the project is created and an entry in the collaborator table is created linking the user with the project having the role of “manager”.
    - If anyone was invited to the project, then their collaborator records will be created with the role of “invited”.
- They can click **cancel** which directs back to **/projects**

## /projects/:id

- This is the main view for a project.
- two main sections
    - Sidebar: Same as sidebar in **/projects**
    - Main View:
        - Header Section:
            - The title of the project
            - The description of the project
            - Collaborators summary view and a link to collaborators page **/projects/:id/collaborators** page
                - It will be an arrangement of collaborator profile pictures. or it would be a list of collaborator display names. and maybe some metrics…. STILL NEEDS TO BE TEASED OUT
                - You could click on the the on a specific collaborator and directed to **/projects/:id/collaborators/:id**
                - + button that opens the form at **/projects/:id/collaborators/new**
        - Task List Summary Section
            - This will be a table showing the list of tasks.
            - You can filter this table based on the following attributes:
                - task priority
                - task due date (optional)
                - task status (default for manager, where “In Review” Status is first)
                - task assignee (default for developer, where they are the assignee is first)
            - If you’re a **manager,** you will see a “+” button next to the table where you will be taken to **/projects/:id/tasks/new** to create a task. You will not see this button if you are a developer.
            - A single entry in the task list will show
                - task name
                - task status
                - task priority
                - task due date
                - task assignee
            - You can click a single entry in this table and be taken to **/projects/:id/tasks/:id**

## /projects/:id/tasks/:id

- This is the detailed view of a task. there will be 4 sections
    - Task Description
        - This will contain the Title of the task
        - The description of the task.
        - The optional github branch link
    - Task Summary
        - The task status
            - Only editable through the “request a review” flow or if the manager unassigns someone (see right below)
        - Task priority
            - Manager can click this and immediately select another priority.
        - Task Due date
            - Manager can click this field and directly edit the date.
        - Task assignee
            - Manager can click the dropdown and select another group member to do the task. If they select “no assignee” (the state where no user is assigned) then the project status goes back to “Todo”
    - Task Media
        - This section will include support for media upload. For example: a figma file for a UI redesign, or a jpeg of a mock UI, or a photo of an ERD for a database refactor
        - NICE TOUCH: make the small view of the file still show the contents, kind of like on mac os in the finder.
    - Task Comments: (Required, New Table required probably)
        - This section will be a message board for any collaborator to make a comment on the
    - If you’re a developer assigned to a task:
        - You can click the “Request Review” button. This will change the status of the project to “In Review”
    - If the task is in review, when the manager see’s the page they will scroll down and see two buttons: “Mark as Complete” or “Reject Change”.
        - “Mark as complete” will change the task status to complete
        - “Reject change” will change the task status back to “In Progress”. Followed by a comment popup where the manager will write a comment about needs to be changed. This will then update the comment table for the application.

## **/projects/:id/tasks/new**

- This is a page only accessible by the manager. Anyone else who tries to access this should be forbidden.
- This is the page where a manager can create a task.
- It will be a form with:
    - Name
    - Description
    - Branch Link (optional) (Default None)
    - Assignee (Optional) (Default None)
        - If someone is assigned, then that **task status** is immediately set to “In Progress”.
        - If someone is not assigned, then the **task status** is set to “Todo”.
    - Priority (Optional) (Default None)
- If the user clicks create task, the task will be created and they will be redirected to the task page**: /projects/:id/tasks/:id**
- If they click cancel they will be redirected to the projects page: **/projects/:id**

## **/projects/:id/collaborators**

- Shows all collaborators in the project
- A list view or card view:
    - Shows the collaborator display name.
    - Shows the their contribution percentage (completed tasks / total tasks in the project)
    - ….
- Should be accessible to everyone

## **/projects/:id/collaborators/new**

- Shows a form to input an email to send an invite (or just directly add someone)
- Only visible to manager
- if no user with that name or email found, then the manager is alerted “User not found”.

## **/projects/:id/collaborators/:id**

- Shows information on a specific collaborator
- Shows contribution graph???? (Cool feature but difficult)
- Shows the their contribution percentage (completed tasks / total tasks in the project)
- Stats:
    - A table filtered by status:
        1. In progress
        2. In Review
        3. Completed

## **/projects/:id/collaborators/:id/edit**

- Edit a collaborator’s role or remove a collaborator (probably just remove because there’s only 2 roles)
- Sends PATCH /projects/:id/collaborators/:id if editing
- Sends DELETE /projects/:id/collaborators/:id if deleting
- All collaborators’ edit pages are visible to manager, while developers can only see their own edit page
- If a manager leaves a project, should the project be deleted? Hmm

Users will also have different roles on a project. 

- Manager:
    - Makes / assigns tasks
- Developer:
    - Completes tasks.

When someone creates a project their role will be a manager. 

When someone joins a project, their default role will be a developer. Can be changed to a manager from the manager. 

| **Tasks** | **Type** | **Example Values** |
| --- | --- | --- |
| id | int (autogenerated) PK | 0, 1, …., 1234 |
| Name | string | “Refactor Frontend” |
| Description | string | “Change site font family to Comic Sans” 🙂 |
| Status | Enum | “Todo”, “In Progress”, “In Review”, “Completed”

If not assigned: “Todo”
If assigned: “In Progress” |
| Created At | Date | Dec, 6 3:32 PM  |
| Due At | Date | Dec, 7 5:00 PM |
| Last Updated | Date | Dec, 6 4:00 PM |
| Priority | Enum (optional) | “No Priority”, “Low”, “Medium“, “High”, “Urgent” |
| assignee | int (collaborator id) FK | 1 (wes) |
| branch link  | link (optional) | “github.com/repo/branch” |
| completed at | Date | Dec, 6 4:00 PM |
| type | string | “Bug”, “Feature”, etx.. |

| **Collaborators** | **Type** | Example Values |
| --- | --- | --- |
| id | int PK | 0 |
| user_id | int FK | 1 (wes) |
| project_id | int FK | 3 (jiralite) |
| role | enum | “Developer”, “Manager”, “Invited” |
| created at | datetime | Dec, 6 4:00 PM |
| updated at (may not need) | datetime | Dec, 6 4:00 PM |

| **Projects** | **Type** | Example Values |
| --- | --- | --- |
| Id | int PK | 1 |
| name | string | “Jira Lite” |
| created_at | datetime | Dec, 6 4:00 PM |
| updated_at | datetime | Dec, 6 4:00 PM |
| project repo | link | github.com/repo |
| description  | string | “building a task tracking software” |

| **Users**  | **Type** | **Example Values** |
| --- | --- | --- |
| id | int PK | 1 |
| username | string | “wes” |
| email address | string | “wes@email.com” |
| password_digest | string | ? |
| reset_password_token | string | ? |

| Comments | Type | Example Values |
| --- | --- | --- |
| id  | int PK | 1 |
| comment | string 256 ? | “Wes is dumb” |
| collaborator id | int FK | 1 (wes) |
| task id | int FK | 1 (create unicorn) |

**active_storage_blobs**

| Column Name | Type | Example Values |
| --- | --- | --- |
| id | integer (primary key) | 1, 2, 3 |
| key | string (unique) | "abc123def456ghi789", "xyz789uvw456rst123" |
| filename | string | "screenshot.png", "design-doc.pdf", "logo.svg" |
| content_type | string | "image/png", "image/jpeg", "image/svg+xml", "application/pdf" |
| metadata | text (JSON) | "{}", "{\"identified\":true,\"width\":1920,\"height\":1080}" |
| service_name | string | "local", "amazon", "google" |
| byte_size | bigint | 1048576, 5242880, 2048000 |
| checksum | string | "abc123def456...", "xyz789uvw456..." |
| created_at | datetime | "2025-12-08 10:30:00", "2025-12-08 14:22:15" |

## **active_storage_attachments**

| Column Name | Type | Example Values |
| --- | --- | --- |
| id | integer (primary key) | 1, 2, 3 |
| name | string | "media_files", "documents", "attachments" |
| record_type | string | "Task", "Project", "User" |
| record_id | integer | 42, 15, 7 |
| blob_id | integer (foreign key) | 1, 2, 3 |
| created_at | datetime | "2025-12-08 10:30:00", "2025-12-08 14:22:15" |

Schema Validations.

User Flow Validation.

We need robust testing. 

We need good mock data for the application. 

For the Demo.

## Nice Touches:

- If it is the users first time logging in, then we give them a walkthrough / tutorial on how to use the application. Definitely not necessary but nice to have.
- Update enum objects on a task based by right clicking the task on a projects page.
- Calendar View Page.
- Manager has the ability to send an invite link to a user where they can join a project by clicking an email link…
- Manager Email Notification for a task review…
- Developer Metrics Page for in a Project. Showing managers select metrics on all of their developers… Like velocity… etc..