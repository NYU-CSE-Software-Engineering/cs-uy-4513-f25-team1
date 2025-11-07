## Projects UI

### User stories
- As a signed-in user, I can create a project by providing a required Name and optional Key/Description.
- As a project admin, I can configure WIP limits per status in project settings.

### Acceptance criteria
1. Create project: From Projects page, clicking New Project opens the form. Name is required.
2. Success shows a flash notice and redirects to the project page with status columns.
3. Failure (blank Name) shows a validation error.
4. Settings: Admin can set WIP limits per status and save; limits reflect on the board.
5. Non-admins cannot save settings; they see a permission error.


