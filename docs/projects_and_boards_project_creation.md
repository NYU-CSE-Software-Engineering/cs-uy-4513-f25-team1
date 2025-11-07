## Feature: Project + default board creation

### User story
As a signed-in user, I want to create a project that comes with a default board so I can start organizing work immediately.

### Acceptance criteria
1. Any signed-in user can create a project by providing a required name.
2. Creator becomes Project Admin for that project.
3. Default board name is "Main Board" with default columns: To Do, In Progress, Done.
4. Duplicate project names allowed globally (no cross-project uniqueness enforced).
5. Failure: name missing shows an error.

### MVC outline
- Models: `Project(name)`, `ProjectMembership(user, project, role: {admin, member})`; `Board(project, name)`, `BoardColumn(board, name, position)`
- Controllers: `ProjectsController(new, create, show)`; `BoardsController(show)`
- Views: `projects/new`, `projects/show`


