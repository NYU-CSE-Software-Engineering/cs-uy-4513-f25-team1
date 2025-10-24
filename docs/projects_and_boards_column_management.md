## Feature: Board column management (admin-only)

### User story
As a project admin, I want to manage board columns so I can tailor workflow stages.

### Acceptance criteria
1. Admin can add, rename, delete, and reorder columns.
2. Column name required and unique per board (case-insensitive).
3. Deleting a column requires confirmation and removes its cards (behavior TBD; initially show a warning and proceed).
4. Non-admin users cannot modify columns and see a permission error.
5. Reorder via Up/Down controls reflects immediately in UI.
6. Failure: blank or duplicate column name shows validation error.

### MVC outline
- Models: `BoardColumn(name, position, board:belongs_to)`
- Controllers: `BoardColumnsController(create, update, destroy)`; `reorder` (non-drag)
- Views: `boards/show` with admin-only controls


