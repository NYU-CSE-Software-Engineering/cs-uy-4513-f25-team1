# User Story
**As a** user  
**I want to** create a new project  
**So that I can** organize tasks and manage progress  

## Acceptance Criteria
* Any signed-in user can create a project.
* A project must have a unique name and key.
* Description is optional.
* After creation, the project creator becomes the project admin.
* Other users can later be added to the project with specific roles (e.g. Developer, Viewer).

# Task 3: Model-View-Controller

## Model
A `Project` model with these fields:  
* name:string  
* key:string  
* description:text  
* created_by:references (User)

A `ProjectUser` model representing membership and roles within each project:  
* user_id:references  
* project_id:references  
* role:string (values: 'Admin', 'Developer', 'Customer')

### Relationships:
* `User` has many `projects` through `ProjectUser`
* `Project` has many `users` through `ProjectUser`
* `ProjectUser` belongs to both `User` and `Project`

Validations:
* `name` and `key` must be present and unique
* `description` is optional

## View
A `projects/new.html.erb` page that contains a form for creating a project.  
The form includes fields for **Name**, **Key**, and **Description**, plus a “Create Project” button.  
After creation, redirect to the project’s show page.  
If creation fails, re-render the form with error messages.

## Controller
A `ProjectsController` with:  
* `new` – shows the new project form  
* `create` – creates a new project; associates it with the currently logged-in user  
* `show` – displays project details and member list  
