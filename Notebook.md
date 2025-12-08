# Software Engineering Final Project

## Current State:

- Basic Database scheme (to be changed as need)
- Landing Page (Inconsequential)
- Features Page (Inconsequential)
- Insufficient Testing (even for the limited features we have)
- Basic User Authentication Working (This is good)

## Model:

(Need to get an up to date schema Diagram. Some ideas below in table)

## Views:

TBA

## Controller

Users will also have different roles on a project. 

- Manager:
    - Makes / assigns tasks
- Developer:
    - Completes tasks.

When someone creates a project their role will be a manager. 

When someone joins a project, their default role will be a developer. 

## Next Steps (Brain Dump):

- Post Login Landing Page:
    - User Logs in, then what do they immediately see?
        - The user should see the a page that has a sidebar showing all projects on  the left.
            - Sidebar has the list of projects the user is apart of cascading down from the top. A user is linked to a project via the collaborator table. the projects should be ordered in two sections: Manager Projects & Developer Projects.
                - the top list will be all of the projects that user is a manager of ordered by most recently accessed from top down.
                - The bottom list will be all of the projects that user is a developer on also ordered by most recently accessed from top down.
            - The bottom of the sidebar has the settings menu, a join project, and create project button
        - If the user does not have any projects right side should have two cards:
            - One saying to create a project. takes them to a create projects page.
                - Make sure they pass all project validations.
                - Once they create a project, They are redirected to that project page, and the the project appears in the sidebar.
            - One saying join project. takes them to a page where they enter a code to join the project.
                - This page has a simple text input, where the user enters a code to join a project. If they enter an incorrect, the page tells them that the code they entered is invalid. If they enter the correct code, then they are added to the project as a collaborator and redirected to that project page.
        - If the user has projects, they should see the their most recent project opened.
            - A project is comprised of many tasks. A project also has a description, describing what the project is. That will be at the top of the page. It will also a conglomerate list of collaborators on the project. the user will also see tasks assigned to them at the top of the page. There will also be a layout filter at the top of the page, where a user can show choose whether they want to see the project tasks in a variety of ways: List view, card view, or calendar.
            - A Developer will first see the tasks assigned to them.
            - The project page will have multiple views.
                - List view which just shows tasks in a list. sortable on different keys: Due Date, Urgency, etc..
                    - A single row will have summary information about a task: Assignee, Due Date, Progress, etc…
                    - A card view which has a row, col layout, and the card has the same summary information.
                    - Calendar View shows the tasks in a calendar filtered by due date.  ((Extra))
        - When a developer clicks on a task:
            - The task page opens. It will show a description of the task, who is assigned to it, an optional link to open a specific github branch, An optional checklist, only editable by the either the assigned developer or the manager.
                - If a developer checks the last item in the checklist, a popup will appear asking them if they want to request a review.
                - If a manager checks the last checklist item, the manager will be prompted if they want to mark the task as complete.
            - There will be a media upload for only the manager / developer to upload artifacts.
            - There will be a comment section where anyone on the project can leave a comment about a task.
            - At the top of the page a user can click a “request review” button. This will change the status of the
        - When a manager creates a task. They must at a minimum give it a title and description. They can optionally assign a user to it. If they do then the project is automatically marked with a status of “In Progress”. If they do not assign a user to it then it is default marked as “Todo”. Only the Manager and Assigned Developer can change the task status.

- the manager will have the ability to mark the project as complete or not.
    - If the manager says complete, then the project goes from “In review” → “Completed”
    - if the manager decides that that is not completed then the project will go from “In Review → “In Progress”
- the manager flow will be as follows:
    - When they login to the project, they will see all of the “In Review” tasks.
    - They click on a specific “In Review” Task and are brought to the task page
    - They scroll through, looking at media & comments. At the bottom they click a “Mark as completed button” or they click a “Needs Work” button
        - If they click the “Mark as completed button” then the task status is changed to completed and the manager is redirected to the project page.
        - If they click “Need Work”, then a comment box pops up where they leave a comment specifying they cannot mark it complete. This comment is then left in the comment section. and the status is changed and the manager is redirected to the Project main page.
- A Developer can leave a project if they want to. In the sidebar the, there will be a red button “Leave Project”. If they click it, they will be prompted “Are you Sure”. If no, then the popup closes and nothing happens. If they click “yes” then their collaborator record in the database is destroyed and the developer is redirected to the page showing “Create Project” or “Join Project”
- Project Settings Page is a page only the manager can see. The can edit the project name and project description. They can also remove users on the project from this page. the

| **Tasks** | **Type** | **Example Values** |
| --- | --- | --- |
| id | int (autogenerated) PK | 0, 1, …., 1234 |
| title | string | “Refactor Frontend” |
| Description | string | “Change site font family to Comic Sans” |
| Status | Enum | “Todo”, “In Progress”, “In Review”, “Completed” |
| Created At | Date | Dec, 6 3:32 PM  |
| Due At | Date | Dec, 7 5:00 PM |
| Last Updated | Date | Dec, 6 4:00 PM |
| Priority | Enum (optional) | “No Priority”, “Low”, “Medium“, “High”, “Urgent”

If not assigned: “Todo”
If assigned: “In Progress” |
| assignee | int (collaborator id) FK | 1 (wes) |
| branch link  | link (optional) | “github.com/repo/branch” |

| **Collaborators** | **Type** | Example Values |
| --- | --- | --- |
| id | int PK | 0 |
| user_id | int FK | 1 (wes) |
| project_id | int FK | 3 (jiralite) |
| role | enum | “Developer”, “Collaborator” |
| created at | datetime | Dec, 6 4:00 PM |
| updated at (may not need) | datetime | Dec, 6 4:00 PM |

| **Projects** | **Type** | Example Values |
| --- | --- | --- |
| Id | int PK | 1 |
| Title | string | “Jira Lite” |
| WIP_Limit (Probably going to get rid of) | int | 2 |
| key | string | “JIRA” |
| created_at | datetime | Dec, 6 4:00 PM |
| updated_at | datetime | Dec, 6 4:00 PM |

| **Users**  | **Type** | **Example Values** |
| --- | --- | --- |
| id | int PK | 1 |
| username | string | “wes” |
| email address | string | “wes@email.com” |
| password_digest | string | ? |
| reset_password_token | string | ? |

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