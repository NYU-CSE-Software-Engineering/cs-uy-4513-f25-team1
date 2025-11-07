# Project Directory Tree

```
cs-uy-4513-f25-team1/
│
├── .git/                          # Git version control
├── .github/                       # GitHub configuration
├── .kamal/                        # Kamal deployment configuration
│
├── app/                           # Main application code
│   ├── assets/
│   │   ├── images/               # Image assets (.keep file)
│   │   └── stylesheets/
│   │       └── application.css   # Main stylesheet
│   │
│   ├── controllers/              # MVC Controllers
│   │   ├── concerns/             # Controller concerns (.keep)
│   │   ├── application_controller.rb
│   │   ├── projects_controller.rb
│   │   └── tasks_controller.rb
│   │
│   ├── helpers/                  # View helpers
│   │   └── application_helper.rb
│   │
│   ├── javascript/               # JavaScript assets
│   │   ├── controllers/          # Stimulus controllers
│   │   │   ├── application.js
│   │   │   ├── hello_controller.js
│   │   │   └── index.js
│   │   └── application.js
│   │
│   ├── jobs/                     # Background jobs
│   │   └── application_job.rb
│   │
│   ├── mailers/                  # Email templates
│   │   └── application_mailer.rb
│   │
│   ├── models/                   # MVC Models
│   │   ├── concerns/             # Model concerns (.keep)
│   │   ├── application_record.rb
│   │   ├── project.rb
│   │   └── task.rb
│   │
│   └── views/                    # ERB templates
│       ├── layouts/
│       │   ├── application.html.erb
│       │   ├── mailer.html.erb
│       │   └── mailer.text.erb
│       ├── pwa/                  # Progressive Web App files
│       │   ├── manifest.json.erb
│       │   └── service-worker.js
│       └── tasks/
│           ├── index.html.erb
│           └── new.html.erb
│
├── bin/                          # Executable scripts
│   ├── brakeman                  # Security scanner
│   ├── dev                       # Development server
│   ├── docker-entrypoint         # Docker entry point
│   ├── importmap                 # JavaScript module mapper
│   ├── jobs                      # Job processor
│   ├── kamal                     # Deployment tool
│   ├── rails                     # Rails CLI
│   ├── rake                      # Rake task runner
│   ├── rubocop                   # Ruby linter
│   ├── setup                     # Setup script
│   └── thrust                    # Thrust CLI
│
├── config/                       # Application configuration
│   ├── environments/
│   │   ├── development.rb
│   │   ├── production.rb
│   │   └── test.rb
│   ├── initializers/
│   │   ├── assets.rb
│   │   ├── content_security_policy.rb
│   │   ├── filter_parameter_logging.rb
│   │   └── inflections.rb
│   ├── locales/
│   │   └── en.yml                # English translations
│   ├── application.rb
│   ├── boot.rb
│   ├── cable.yml                 # Action Cable config
│   ├── cache.yml                 # Cache config
│   ├── credentials.yml.enc       # Encrypted credentials
│   ├── database.yml              # Database config
│   ├── deploy.yml                # Deployment config
│   ├── environment.rb
│   ├── importmap.rb              # JavaScript imports
│   ├── puma.rb                   # Puma server config
│   ├── queue.yml                 # Job queue config
│   ├── recurring.yml             # Recurring jobs config
│   ├── routes.rb                 # URL routing
│   └── storage.yml               # Active Storage config
│
├── db/                           # Database files
│   ├── migrate/                  # Database migrations
│   │   ├── 20251106193016_create_projects.rb
│   │   └── 20251106193020_create_tasks.rb
│   ├── cable_schema.rb           # Action Cable schema
│   ├── cache_schema.rb           # Cache schema
│   ├── queue_schema.rb           # Queue schema
│   ├── schema.rb                 # Current database schema
│   └── seeds.rb                  # Database seeds
│
├── docs/                         # Project documentation
│   ├── tdd_evidence/             # TDD evidence screenshots
│   │   ├── create_task_red.png
│   │   └── cucumber_red.png
│   ├── board_views.md
│   ├── create_account.md
│   ├── create_project.md
│   ├── filter.md
│   ├── login_account.md
│   ├── logout_account.md
│   ├── project-specification.pdf
│   ├── projects_and_boards_card_crud.md
│   ├── projects_and_boards_column_management.md
│   ├── projects_and_boards_project_creation.md
│   ├── projects_and_boards.md
│   └── projects_ui.md
│
├── features/                     # Cucumber BDD features
│   ├── screenshots/              # Feature screenshots
│   │   ├── board_card_crud_N.png
│   │   ├── board_columns_management_N.png
│   │   ├── board_views_steps_N.png
│   │   ├── filter_1.jpg
│   │   ├── filter_2.jpg
│   │   ├── identity_1.png
│   │   ├── identity_2.png
│   │   ├── identity_3.png
│   │   ├── newproject_1.png
│   │   ├── project_create_steps_N.png
│   │   └── projects_ui_N.png
│   ├── step_definitions/         # Cucumber step definitions
│   │   ├── board_card_crud_steps.rb
│   │   ├── board_columns_management_steps.rb
│   │   ├── board_views_steps.rb
│   │   ├── create_task_steps.rb
│   │   ├── filter_steps.rb
│   │   ├── identity_steps.rb
│   │   ├── newproject_steps.rb
│   │   ├── projects_create_steps.rb
│   │   ├── projects_ui_steps.rb
│   │   └── task_steps.rb
│   ├── support/                  # Cucumber support files
│   │   └── env.rb
│   ├── board_card_crud.feature
│   ├── board_columns_management.feature
│   ├── board_views.feature
│   ├── create_account.feature
│   ├── create_project.feature
│   ├── create_task.feature
│   ├── filter.feature
│   ├── login_account.feature
│   ├── logout.feature
│   ├── projects_create.feature
│   └── projects_ui.feature
│
├── lib/                          # Library code
│   └── tasks/                    # Custom Rake tasks (.keep)
│
├── log/                          # Application logs (.keep)
│
├── public/                       # Public assets
│   ├── 400.html                  # Bad request error page
│   ├── 404.html                  # Not found error page
│   ├── 406-unsupported-browser.html
│   ├── 422.html                  # Unprocessable entity error page
│   ├── 500.html                  # Server error page
│   ├── icon.png
│   ├── icon.svg
│   └── robots.txt
│
├── script/                       # Scripts (.keep)
│
├── spec/                         # RSpec test suite
│   ├── views/
│   │   └── tasks/
│   │       └── create.html.erb_spec.rb
│   ├── requests/
│   │   └── tasks_spec.rb
│   ├── rails_helper.rb
│   └── spec_helper.rb
│
├── storage/                      # Active Storage files (.keep)
│
├── tmp/                          # Temporary files
│   ├── pids/                     # Process IDs (.keep)
│   └── storage/                  # Temporary storage (.keep)
│
├── vendor/                       # Third-party code
│   └── javascript/               # Vendor JavaScript (.keep)
│
├── .dockerignore                 # Docker ignore rules
├── .gitattributes                # Git attributes
├── .gitignore                    # Git ignore rules
├── .rspec                        # RSpec configuration
├── .rubocop.yml                  # RuboCop linter config
├── .ruby-version                 # Ruby version specification
├── config.ru                     # Rack configuration
├── Dockerfile                    # Docker image definition
├── Gemfile                       # Ruby dependencies
├── Gemfile.lock                  # Locked dependency versions
├── Rakefile                      # Rake task definitions
└── README.md                     # Project README
```

## Project Summary

This is a **Rails 7+ application** following **Test-Driven Development (TDD)** practices with:

### Key Technologies:
- **Ruby on Rails** - Web framework
- **Cucumber** - BDD testing (features/)
- **RSpec** - Unit/integration testing (spec/)
- **Stimulus** - JavaScript framework (app/javascript/controllers/)
- **Action Cable** - WebSocket support
- **Active Storage** - File uploads
- **Kamal** - Deployment tool
- **Puma** - Web server
- **RuboCop** - Code linter

### Main Features:
- **Projects & Tasks** - Core domain models (Project, Task)
- **Board Views** - Kanban-style boards
- **User Authentication** - Login/logout/account creation
- **Filtering** - Task filtering functionality
- **Card CRUD** - Create, read, update, delete cards
- **Column Management** - Board column operations

### Testing:
- **11 Cucumber feature files** - BDD acceptance tests
- **RSpec specs** - Unit tests for tasks controller and views
- **TDD evidence** - Screenshots documenting red-green-refactor cycle

### Project Structure:
- Standard Rails MVC architecture
- Separation of concerns (models, views, controllers)
- Feature-based BDD tests
- Comprehensive documentation in `docs/`

