Filter
------

As a signed in user  
I want to filter tasks by their types  
So that I can view relevant tasks  

Acceptance Criteria:  
By default sorts by date created
Can sort by types such as bug, feature, backlog  
Can sort by date modified
Doesn't accept invalid search params


MVC Components
--------------

Models:  
A Task model with type: {bug, feature, backlog, ...}  

Views:  
projects/show.html.erb  
Will show all the tasks and some dropdown menu to select filter and probably a confirm button

Controllers:  
A ProjectsController with a show action that accepts optional query params to sort  
