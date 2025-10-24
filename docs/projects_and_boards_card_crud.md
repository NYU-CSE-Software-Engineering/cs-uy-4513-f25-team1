## Feature: Card CRUD on a board

### User story
As a project member, I want to create, edit, and delete cards in board columns to track work items.

### Acceptance criteria
1. Members can create a card with required title and optional description in a specific column.
2. Members can edit and delete cards.
3. Card appears within the selected column after create/update.
4. Failure: missing title shows validation error.

### MVC outline
- Models: `Card(board_column:belongs_to, author:user, title, description)`
- Controllers: `CardsController(create, update, destroy)`
- Views: `cards/_form` inside `boards/show`


