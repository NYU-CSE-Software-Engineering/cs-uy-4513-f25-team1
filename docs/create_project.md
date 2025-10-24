# User Story
**As an** admin user  
**I want to** create a new project  
**So I can** organize and manage related tasks and issues under it  

## Acceptance Criteria
* Project must have a unique name and key
* Project must include a description field
* Only admin users can create new projects  
* After creation, user is redirected to the project’s board page  
* Missing or duplicate fields display appropriate error messages  

# Task 3: Model-View-Controller

## Model
A `Project` model with the following attributes:  
* name:string  
* key:string  
* description:text  
* created_by:references (User)  

Validations:  
* presence and uniqueness for `name` and `key`  
* optional `description`

## View 
A `projects/new.html.erb` view that displays a form for creating a project.  
Form fields include name, key, and description, with a “Create Project” button.  
On submission:
* Successful creation redirects to `projects/show.html.erb`
* On failure, the same form is re-rendered with error messages.

## Controller
A `ProjectsController` with the following actions:  
* `new`: Displays the project creation form  
* `create`: Handles form submission, validates data, saves a new project, and redirects to the show page if successful  
* `show`: Displays the created project’s details  
