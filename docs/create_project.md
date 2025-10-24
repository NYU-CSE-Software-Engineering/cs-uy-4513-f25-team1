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
A `Project` model with these fields:  
* name:string  
* key:string  
* description:text  
* created_by:references (User)

Validations:  
* `name` and `key` must be present and unique  
* `description` is optional  

## View
A `projects/new.html.erb` page with a form for creating a project.  
The form includes fields for name, key, and description, and a “Create Project” button.  
If creation succeeds, it redirects to the project’s show page.  
If it fails, it shows error messages on the same form.  

## Controller
A `ProjectsController` with:  
* `new` – shows the project creation form  
* `create` – saves the project and redirects or shows errors  
* `show` – displays the project details 
