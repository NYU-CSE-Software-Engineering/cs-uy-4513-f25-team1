# Clear existing data
puts "Cleaning database..."
Collaborator.destroy_all
Task.destroy_all
Project.destroy_all
User.destroy_all

puts "Creating users..."
users = FactoryBot.create_list(:user, 5)
main_user = FactoryBot.create(:user, email_address: "test@example.com", username: "tester", password: "password", password_confirmation: "password")
users << main_user

puts "Creating projects..."

# =============================================================================
# 1. Empty Project - No tasks, only manager
# =============================================================================
empty_project = FactoryBot.create(:project, name: "Empty Project", description: "An empty project for testing")
Collaborator.create!(user: main_user, project: empty_project, role: :manager)

# =============================================================================
# 2. Comprehensive Tasks Project - Covers all valid task attribute combinations
# =============================================================================
comprehensive_project = FactoryBot.create(:project,
  name: "Comprehensive Tasks Project",
  description: "Project with tasks covering all valid attribute combinations",
  repo: "https://github.com/team/comprehensive-project"
)
comp_manager = Collaborator.create!(user: main_user, project: comprehensive_project, role: :manager)
comp_dev1 = Collaborator.create!(user: users[0], project: comprehensive_project, role: :developer)
comp_dev2 = Collaborator.create!(user: users[1], project: comprehensive_project, role: :developer)

# --- Status Coverage: All 4 statuses ---
puts "  Creating tasks with all statuses..."

# Todo tasks (unassigned, various priorities)
FactoryBot.create(:task, :todo, :no_priority,
  project: comprehensive_project,
  title: "Unassigned todo - no priority",
  description: "A basic todo task with no priority set"
)
FactoryBot.create(:task, :todo, :low_priority,
  project: comprehensive_project,
  title: "Unassigned todo - low priority",
  description: "A todo task with low priority"
)
FactoryBot.create(:task, :todo, :medium_priority,
  project: comprehensive_project,
  title: "Unassigned todo - medium priority",
  description: "A todo task with medium priority"
)
FactoryBot.create(:task, :todo, :high_priority,
  project: comprehensive_project,
  title: "Unassigned todo - high priority",
  description: "A todo task with high priority"
)
FactoryBot.create(:task, :todo, :urgent_priority,
  project: comprehensive_project,
  title: "Unassigned todo - urgent priority",
  description: "A todo task with urgent priority"
)

# In Progress tasks (assigned to developers)
FactoryBot.create(:task, :in_progress, :medium_priority,
  project: comprehensive_project,
  assignee: comp_dev1,
  title: "In progress task - developer 1",
  description: "Task being actively worked on by developer 1"
)
FactoryBot.create(:task, :in_progress, :high_priority,
  project: comprehensive_project,
  assignee: comp_dev2,
  title: "In progress task - developer 2",
  description: "Task being actively worked on by developer 2"
)

# In Review tasks
FactoryBot.create(:task, :in_review, :medium_priority,
  project: comprehensive_project,
  assignee: comp_dev1,
  title: "In review task - awaiting approval",
  description: "Task completed and awaiting code review"
)

# Completed tasks
FactoryBot.create(:task, :completed, :low_priority,
  project: comprehensive_project,
  assignee: comp_dev1,
  title: "Completed task with assignee",
  description: "A task that was completed by developer 1"
)
FactoryBot.create(:task, :completed, :medium_priority,
  project: comprehensive_project,
  title: "Completed task without assignee",
  description: "A task that was completed but had no assignee"
)

# --- Type Coverage: All task types ---
puts "  Creating tasks with all types..."

FactoryBot.create(:task, :todo, :bug, :high_priority,
  project: comprehensive_project,
  title: "Bug: Login fails with special characters",
  description: "Users cannot login when password contains special characters like @\#$"
)
FactoryBot.create(:task, :in_progress, :feature, :medium_priority,
  project: comprehensive_project,
  assignee: comp_dev1,
  title: "Feature: Add dark mode toggle",
  description: "Implement a toggle switch in settings to enable dark mode theme"
)
FactoryBot.create(:task, :todo, :improvement, :low_priority,
  project: comprehensive_project,
  title: "Improvement: Optimize database queries",
  description: "Refactor N+1 queries in the tasks listing page"
)
FactoryBot.create(:task, :in_review, :chore, :no_priority,
  project: comprehensive_project,
  assignee: comp_dev2,
  title: "Chore: Update dependencies",
  description: "Update all gems to latest stable versions"
)
FactoryBot.create(:task, :todo, :documentation, :low_priority,
  project: comprehensive_project,
  title: "Documentation: API endpoints guide",
  description: "Write comprehensive documentation for all REST API endpoints"
)

# --- Due Date Coverage: Past, today, soon, later, none ---
puts "  Creating tasks with various due dates..."

FactoryBot.create(:task, :todo, :urgent_priority, :due_past,
  project: comprehensive_project,
  title: "Overdue task - past due date",
  description: "This task has a due date in the past and needs immediate attention"
)
FactoryBot.create(:task, :in_progress, :high_priority, :due_today,
  project: comprehensive_project,
  assignee: comp_dev1,
  title: "Due today - urgent delivery",
  description: "This task must be completed by end of today"
)
FactoryBot.create(:task, :todo, :medium_priority, :due_soon,
  project: comprehensive_project,
  title: "Due soon - within a week",
  description: "This task is due within the next 7 days"
)
FactoryBot.create(:task, :todo, :low_priority, :due_later,
  project: comprehensive_project,
  title: "Due later - next month",
  description: "This task is scheduled for completion next month"
)

# --- Branch Link Coverage ---
puts "  Creating tasks with branch links..."

FactoryBot.create(:task, :in_progress, :medium_priority, :feature, :with_branch,
  project: comprehensive_project,
  assignee: comp_dev1,
  title: "Feature with active branch",
  description: "Feature development with associated git branch"
)
FactoryBot.create(:task, :in_review, :high_priority, :bug, :with_branch,
  project: comprehensive_project,
  assignee: comp_dev2,
  title: "Bug fix in review with branch",
  description: "Bug fix submitted for review with branch link",
  branch_link: "https://github.com/team/project/tree/fix/critical-bug-123"
)

# =============================================================================
# 3. Priority Matrix Project - All priorities across different statuses
# =============================================================================
priority_project = FactoryBot.create(:project,
  name: "Priority Matrix Project",
  description: "Project demonstrating all priority levels across task statuses"
)
priority_manager = Collaborator.create!(user: main_user, project: priority_project, role: :manager)
priority_dev = Collaborator.create!(user: users[2], project: priority_project, role: :developer)

puts "  Creating priority matrix tasks..."

# No priority across statuses
FactoryBot.create(:task, :todo, :no_priority, project: priority_project,
  title: "No priority - Todo", description: "Task with no priority in todo status")
FactoryBot.create(:task, :in_progress, :no_priority, project: priority_project, assignee: priority_dev,
  title: "No priority - In Progress", description: "Task with no priority in progress")

# Low priority across statuses
FactoryBot.create(:task, :todo, :low_priority, project: priority_project,
  title: "Low priority - Todo", description: "Low priority task in todo status")
FactoryBot.create(:task, :in_progress, :low_priority, project: priority_project, assignee: priority_dev,
  title: "Low priority - In Progress", description: "Low priority task in progress")
FactoryBot.create(:task, :completed, :low_priority, project: priority_project,
  title: "Low priority - Completed", description: "Low priority task completed")

# Medium priority across statuses
FactoryBot.create(:task, :todo, :medium_priority, project: priority_project,
  title: "Medium priority - Todo", description: "Medium priority task in todo status")
FactoryBot.create(:task, :in_review, :medium_priority, project: priority_project, assignee: priority_dev,
  title: "Medium priority - In Review", description: "Medium priority task in review")
FactoryBot.create(:task, :completed, :medium_priority, project: priority_project,
  title: "Medium priority - Completed", description: "Medium priority task completed")

# High priority across statuses
FactoryBot.create(:task, :todo, :high_priority, project: priority_project,
  title: "High priority - Todo", description: "High priority task requiring attention")
FactoryBot.create(:task, :in_progress, :high_priority, project: priority_project, assignee: priority_dev,
  title: "High priority - In Progress", description: "High priority task actively being worked on")
FactoryBot.create(:task, :in_review, :high_priority, project: priority_project, assignee: priority_dev,
  title: "High priority - In Review", description: "High priority task awaiting review")
FactoryBot.create(:task, :completed, :high_priority, project: priority_project,
  title: "High priority - Completed", description: "High priority task successfully completed")

# Urgent priority across statuses
FactoryBot.create(:task, :todo, :urgent_priority, project: priority_project,
  title: "Urgent - Todo", description: "Critical task requiring immediate action")
FactoryBot.create(:task, :in_progress, :urgent_priority, project: priority_project, assignee: priority_dev,
  title: "Urgent - In Progress", description: "Critical task being worked on now")
FactoryBot.create(:task, :completed, :urgent_priority, project: priority_project,
  title: "Urgent - Completed", description: "Critical task resolved")

# =============================================================================
# 4. Task Types Project - All task types with realistic scenarios
# =============================================================================
types_project = FactoryBot.create(:project,
  name: "Task Types Showcase",
  description: "Project demonstrating all task types with realistic descriptions",
  repo: "https://github.com/team/task-types-showcase"
)
types_manager = Collaborator.create!(user: main_user, project: types_project, role: :manager)
types_dev = Collaborator.create!(user: users[3], project: types_project, role: :developer)

puts "  Creating task type examples..."

# Multiple bugs with varying priorities
FactoryBot.create(:task, :todo, :bug, :urgent_priority, :due_today,
  project: types_project,
  title: "Bug: Production server crash on high load",
  description: "Server returns 500 errors when more than 100 concurrent users are active"
)
FactoryBot.create(:task, :in_progress, :bug, :high_priority, :with_branch,
  project: types_project, assignee: types_dev,
  title: "Bug: Incorrect date formatting in reports",
  description: "Dates show as MM/DD/YYYY instead of user's locale preference",
  branch_link: "https://github.com/team/project/tree/fix/date-formatting"
)
FactoryBot.create(:task, :completed, :bug, :medium_priority,
  project: types_project, assignee: types_dev,
  title: "Bug: Email notifications not sent",
  description: "Fixed SMTP configuration that prevented email delivery"
)

# Multiple features
FactoryBot.create(:task, :todo, :feature, :high_priority, :due_soon,
  project: types_project,
  title: "Feature: Two-factor authentication",
  description: "Implement TOTP-based 2FA for enhanced account security"
)
FactoryBot.create(:task, :in_progress, :feature, :medium_priority, :with_branch,
  project: types_project, assignee: types_dev,
  title: "Feature: Export tasks to CSV",
  description: "Allow users to export their task list as CSV file",
  branch_link: "https://github.com/team/project/tree/feature/csv-export"
)
FactoryBot.create(:task, :in_review, :feature, :medium_priority, :with_branch,
  project: types_project, assignee: types_dev,
  title: "Feature: Task templates",
  description: "Create reusable task templates for common workflows",
  branch_link: "https://github.com/team/project/tree/feature/task-templates"
)

# Multiple improvements
FactoryBot.create(:task, :todo, :improvement, :medium_priority,
  project: types_project,
  title: "Improvement: Faster page load times",
  description: "Implement lazy loading and caching to reduce initial page load"
)
FactoryBot.create(:task, :in_progress, :improvement, :low_priority,
  project: types_project, assignee: types_dev,
  title: "Improvement: Better error messages",
  description: "Replace generic errors with user-friendly explanations"
)

# Multiple chores
FactoryBot.create(:task, :todo, :chore, :low_priority, :due_later,
  project: types_project,
  title: "Chore: Database backup automation",
  description: "Set up automated daily database backups to cloud storage"
)
FactoryBot.create(:task, :completed, :chore, :no_priority,
  project: types_project,
  title: "Chore: Remove deprecated API endpoints",
  description: "Cleaned up legacy v1 API endpoints no longer in use"
)

# Multiple documentation tasks
FactoryBot.create(:task, :todo, :documentation, :medium_priority,
  project: types_project,
  title: "Documentation: User onboarding guide",
  description: "Create step-by-step guide for new users getting started"
)
FactoryBot.create(:task, :in_review, :documentation, :low_priority,
  project: types_project, assignee: types_dev,
  title: "Documentation: API authentication",
  description: "Document OAuth2 flow and API key management"
)

# Tasks without type (nil type)
FactoryBot.create(:task, :todo, :medium_priority,
  project: types_project,
  title: "General task without type",
  description: "A task that doesn't fit into any specific category"
)

# =============================================================================
# 5. Assignee Scenarios Project - Various assignee configurations
# =============================================================================
assignee_project = FactoryBot.create(:project,
  name: "Assignee Scenarios",
  description: "Project testing various assignee configurations"
)
assign_manager = Collaborator.create!(user: main_user, project: assignee_project, role: :manager)
assign_dev1 = Collaborator.create!(user: users[0], project: assignee_project, role: :developer)
assign_dev2 = Collaborator.create!(user: users[1], project: assignee_project, role: :developer)
assign_dev3 = Collaborator.create!(user: users[2], project: assignee_project, role: :developer)

puts "  Creating assignee scenario tasks..."

# Unassigned tasks (nil assignee)
FactoryBot.create(:task, :todo, :high_priority, project: assignee_project,
  title: "Unassigned - Available for pickup",
  description: "Task available for any developer to claim")
FactoryBot.create(:task, :todo, :medium_priority, project: assignee_project,
  title: "Unassigned - Needs triage",
  description: "Task needs to be assigned during next sprint planning")
FactoryBot.create(:task, :todo, :urgent_priority, project: assignee_project,
  title: "Unassigned - Urgent and unclaimed",
  description: "Critical task that needs immediate assignment")

# Tasks assigned to different developers
FactoryBot.create(:task, :in_progress, :high_priority, project: assignee_project, assignee: assign_dev1,
  title: "Assigned to Developer 1",
  description: "Task actively being worked on by first developer")
FactoryBot.create(:task, :in_progress, :medium_priority, project: assignee_project, assignee: assign_dev2,
  title: "Assigned to Developer 2",
  description: "Task actively being worked on by second developer")
FactoryBot.create(:task, :in_progress, :low_priority, project: assignee_project, assignee: assign_dev3,
  title: "Assigned to Developer 3",
  description: "Task actively being worked on by third developer")

# Multiple tasks per developer
FactoryBot.create(:task, :in_progress, :urgent_priority, project: assignee_project, assignee: assign_dev1,
  title: "Developer 1 - Second task",
  description: "Another task for developer 1 demonstrating multiple assignments")
FactoryBot.create(:task, :in_review, :medium_priority, project: assignee_project, assignee: assign_dev1,
  title: "Developer 1 - In review",
  description: "Developer 1's completed work awaiting review")

# Completed tasks with and without assignees
FactoryBot.create(:task, :completed, :high_priority, project: assignee_project, assignee: assign_dev2,
  title: "Completed by Developer 2",
  description: "Task successfully completed by developer 2")
FactoryBot.create(:task, :completed, :medium_priority, project: assignee_project,
  title: "Completed without assignee",
  description: "Historical task completed before assignee tracking")

# =============================================================================
# 6. Due Date Scenarios Project - Various due date configurations
# =============================================================================
due_date_project = FactoryBot.create(:project,
  name: "Due Date Scenarios",
  description: "Project demonstrating various due date configurations"
)
due_manager = Collaborator.create!(user: main_user, project: due_date_project, role: :manager)
due_dev = Collaborator.create!(user: users[4], project: due_date_project, role: :developer)

puts "  Creating due date scenario tasks..."

# Overdue tasks (past due dates)
FactoryBot.create(:task, :todo, :urgent_priority, project: due_date_project,
  title: "Severely overdue - 2 weeks ago",
  description: "Task that was due 2 weeks ago and needs immediate attention",
  due_at: 2.weeks.ago)
FactoryBot.create(:task, :in_progress, :high_priority, project: due_date_project, assignee: due_dev,
  title: "Overdue - 3 days ago",
  description: "Task that missed deadline by 3 days",
  due_at: 3.days.ago)
FactoryBot.create(:task, :todo, :medium_priority, project: due_date_project,
  title: "Overdue - yesterday",
  description: "Task that was due yesterday",
  due_at: 1.day.ago)

# Due today
FactoryBot.create(:task, :in_progress, :urgent_priority, project: due_date_project, assignee: due_dev,
  title: "Due today - morning deadline",
  description: "Must be completed by end of business today",
  due_at: Time.current.end_of_day)

# Due soon (within a week)
FactoryBot.create(:task, :todo, :high_priority, project: due_date_project,
  title: "Due tomorrow",
  description: "Task due tomorrow",
  due_at: 1.day.from_now)
FactoryBot.create(:task, :todo, :medium_priority, project: due_date_project,
  title: "Due in 3 days",
  description: "Task due in 3 days",
  due_at: 3.days.from_now)
FactoryBot.create(:task, :in_progress, :medium_priority, project: due_date_project, assignee: due_dev,
  title: "Due in 5 days",
  description: "Task due in 5 days",
  due_at: 5.days.from_now)

# Due later (more than a week)
FactoryBot.create(:task, :todo, :low_priority, project: due_date_project,
  title: "Due next week",
  description: "Task scheduled for next week",
  due_at: 1.week.from_now)
FactoryBot.create(:task, :todo, :low_priority, project: due_date_project,
  title: "Due in 2 weeks",
  description: "Task with 2 week deadline",
  due_at: 2.weeks.from_now)
FactoryBot.create(:task, :todo, :no_priority, project: due_date_project,
  title: "Due next month",
  description: "Long-term task due next month",
  due_at: 1.month.from_now)
FactoryBot.create(:task, :todo, :no_priority, project: due_date_project,
  title: "Due in 3 months",
  description: "Future roadmap item",
  due_at: 3.months.from_now)

# No due date (nil)
FactoryBot.create(:task, :todo, :medium_priority, project: due_date_project,
  title: "No due date - backlog item",
  description: "Backlog task with no specific deadline")
FactoryBot.create(:task, :in_progress, :low_priority, project: due_date_project, assignee: due_dev,
  title: "No due date - ongoing maintenance",
  description: "Continuous improvement task with no deadline")

# Completed tasks with various due dates
FactoryBot.create(:task, :completed, :high_priority, project: due_date_project, assignee: due_dev,
  title: "Completed on time",
  description: "Task completed before its due date",
  due_at: 1.week.from_now)
FactoryBot.create(:task, :completed, :medium_priority, project: due_date_project,
  title: "Completed after deadline",
  description: "Task completed but past original due date",
  due_at: 1.week.ago)

# =============================================================================
# 7. Completed Project - All tasks in completed state
# =============================================================================
completed_project = FactoryBot.create(:project,
  name: "Completed Project",
  description: "A project with all tasks successfully completed"
)
Collaborator.create!(user: main_user, project: completed_project, role: :manager)
completed_dev = Collaborator.create!(user: users[0], project: completed_project, role: :developer)

puts "  Creating completed project tasks..."

FactoryBot.create(:task, :completed, :urgent_priority, :bug,
  project: completed_project, assignee: completed_dev,
  title: "Fixed critical security vulnerability",
  description: "Patched SQL injection vulnerability in user search")
FactoryBot.create(:task, :completed, :high_priority, :feature,
  project: completed_project, assignee: completed_dev,
  title: "Implemented user dashboard",
  description: "Built personalized dashboard with activity feed")
FactoryBot.create(:task, :completed, :medium_priority, :improvement,
  project: completed_project,
  title: "Optimized image loading",
  description: "Added lazy loading and WebP support")
FactoryBot.create(:task, :completed, :low_priority, :chore,
  project: completed_project,
  title: "Updated CI/CD pipeline",
  description: "Migrated from Jenkins to GitHub Actions")
FactoryBot.create(:task, :completed, :no_priority, :documentation,
  project: completed_project,
  title: "Wrote deployment guide",
  description: "Documented production deployment procedures")

# =============================================================================
# 8. Invite Test Project - For testing invitation functionality
# =============================================================================
inviter = FactoryBot.create(:user, email_address: "inviter@example.com", username: "inviter", password: "password", password_confirmation: "password")
invite_project = FactoryBot.create(:project, name: "Invite Test Project", description: "Project for testing invites")
Collaborator.create!(user: inviter, project: invite_project, role: :manager)
Collaborator.create!(user: main_user, project: invite_project, role: :invited)

# =============================================================================
# 9. Large Team Project - Many collaborators to test carousel scrolling
# =============================================================================
puts "  Creating large team project..."

large_team_project = FactoryBot.create(:project,
  name: "Large Team Project",
  description: "Project with many team members to test carousel horizontal scrolling",
  repo: "https://github.com/team/large-team-project"
)

# Create additional users for the large team
team_users = []
team_names = %w[alice bob charlie diana edward fiona george hannah ivan julia]
team_names.each do |name|
  team_users << FactoryBot.create(:user,
    email_address: "#{name}@example.com",
    username: name,
    password: "password",
    password_confirmation: "password"
  )
end

# Main user is the manager
large_team_manager = Collaborator.create!(user: main_user, project: large_team_project, role: :manager)

# Add all team users as developers
large_team_devs = team_users.map do |user|
  Collaborator.create!(user: user, project: large_team_project, role: :developer)
end

# Create various tasks assigned to different team members
puts "  Creating tasks for large team..."

# Tasks for first few developers with varying completion rates
FactoryBot.create(:task, :completed, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[0],
  title: "Alice: User authentication", description: "Implemented OAuth2 login")
FactoryBot.create(:task, :completed, :medium_priority, :bug,
  project: large_team_project, assignee: large_team_devs[0],
  title: "Alice: Fixed login redirect", description: "Fixed redirect after login")
FactoryBot.create(:task, :in_progress, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[0],
  title: "Alice: Dashboard widgets", description: "Building dashboard components")

FactoryBot.create(:task, :completed, :urgent_priority, :bug,
  project: large_team_project, assignee: large_team_devs[1],
  title: "Bob: Critical security fix", description: "Patched XSS vulnerability")
FactoryBot.create(:task, :completed, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[1],
  title: "Bob: API endpoints", description: "Created REST API")
FactoryBot.create(:task, :completed, :medium_priority, :improvement,
  project: large_team_project, assignee: large_team_devs[1],
  title: "Bob: Performance optimization", description: "Reduced load time by 40%")
FactoryBot.create(:task, :in_review, :medium_priority, :feature,
  project: large_team_project, assignee: large_team_devs[1],
  title: "Bob: Search functionality", description: "Full-text search implementation")

FactoryBot.create(:task, :completed, :medium_priority, :documentation,
  project: large_team_project, assignee: large_team_devs[2],
  title: "Charlie: API docs", description: "Documented all endpoints")
FactoryBot.create(:task, :in_progress, :low_priority, :chore,
  project: large_team_project, assignee: large_team_devs[2],
  title: "Charlie: Dependency updates", description: "Updating outdated packages")

FactoryBot.create(:task, :completed, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[3],
  title: "Diana: Email notifications", description: "Transactional email system")
FactoryBot.create(:task, :completed, :medium_priority, :bug,
  project: large_team_project, assignee: large_team_devs[3],
  title: "Diana: Email formatting fix", description: "Fixed HTML rendering")
FactoryBot.create(:task, :completed, :low_priority, :improvement,
  project: large_team_project, assignee: large_team_devs[3],
  title: "Diana: Email templates", description: "Redesigned email templates")
FactoryBot.create(:task, :completed, :medium_priority, :feature,
  project: large_team_project, assignee: large_team_devs[3],
  title: "Diana: Webhook integrations", description: "Slack and Discord webhooks")
FactoryBot.create(:task, :in_progress, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[3],
  title: "Diana: Push notifications", description: "Mobile push notification system")

FactoryBot.create(:task, :in_progress, :medium_priority, :feature,
  project: large_team_project, assignee: large_team_devs[4],
  title: "Edward: File uploads", description: "Multi-file upload system")
FactoryBot.create(:task, :todo, :low_priority, :improvement,
  project: large_team_project, assignee: large_team_devs[4],
  title: "Edward: Image compression", description: "Auto-compress uploaded images")

FactoryBot.create(:task, :completed, :high_priority, :bug,
  project: large_team_project, assignee: large_team_devs[5],
  title: "Fiona: Database migration fix", description: "Fixed migration rollback")
FactoryBot.create(:task, :completed, :medium_priority, :chore,
  project: large_team_project, assignee: large_team_devs[5],
  title: "Fiona: Test coverage", description: "Increased coverage to 85%")

FactoryBot.create(:task, :todo, :medium_priority, :feature,
  project: large_team_project, assignee: large_team_devs[6],
  title: "George: Analytics dashboard", description: "Usage analytics visualization")

FactoryBot.create(:task, :completed, :low_priority, :documentation,
  project: large_team_project, assignee: large_team_devs[7],
  title: "Hannah: User guide", description: "End-user documentation")
FactoryBot.create(:task, :in_review, :medium_priority, :documentation,
  project: large_team_project, assignee: large_team_devs[7],
  title: "Hannah: Developer guide", description: "Technical documentation")

FactoryBot.create(:task, :in_progress, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[8],
  title: "Ivan: Payment integration", description: "Stripe payment processing")

FactoryBot.create(:task, :todo, :urgent_priority, :bug,
  project: large_team_project, assignee: large_team_devs[9],
  title: "Julia: Memory leak fix", description: "Investigating memory leak in worker")
FactoryBot.create(:task, :in_progress, :high_priority, :feature,
  project: large_team_project, assignee: large_team_devs[9],
  title: "Julia: Background jobs", description: "Sidekiq job processing")

# =============================================================================
# Summary
# =============================================================================
puts ""
puts "=" * 60
puts "Seeding completed!"
puts "=" * 60
puts ""
puts "Users created:"
puts "  Main User: test@example.com / password"
puts "  Inviter User: inviter@example.com / password"
puts "  Additional users: #{users.count - 1} random users"
puts ""
puts "Projects created: #{Project.count}"
puts "  - Empty Project (0 tasks)"
puts "  - Comprehensive Tasks Project (all attribute combinations)"
puts "  - Priority Matrix Project (all priorities x statuses)"
puts "  - Task Types Showcase (all task types)"
puts "  - Assignee Scenarios (various assignee configs)"
puts "  - Due Date Scenarios (various due date configs)"
puts "  - Completed Project (all tasks completed)"
puts "  - Invite Test Project (invitation testing)"
puts "  - Large Team Project (11 collaborators for carousel testing)"
puts ""
puts "Tasks created: #{Task.count}"
puts "  By status:"
puts "    - Todo: #{Task.todo.count}"
puts "    - In Progress: #{Task.in_progress.count}"
puts "    - In Review: #{Task.in_review.count}"
puts "    - Completed: #{Task.completed.count}"
puts ""
puts "  By priority:"
puts "    - No Priority: #{Task.no_priority.count}"
puts "    - Low: #{Task.low.count}"
puts "    - Medium: #{Task.medium.count}"
puts "    - High: #{Task.high.count}"
puts "    - Urgent: #{Task.urgent.count}"
puts ""
puts "  By type:"
puts "    - Bug: #{Task.where(type: 'Bug').count}"
puts "    - Feature: #{Task.where(type: 'Feature').count}"
puts "    - Improvement: #{Task.where(type: 'Improvement').count}"
puts "    - Chore: #{Task.where(type: 'Chore').count}"
puts "    - Documentation: #{Task.where(type: 'Documentation').count}"
puts "    - No type: #{Task.where(type: nil).count}"
puts ""
puts "  With assignee: #{Task.where.not(assignee_id: nil).count}"
puts "  Without assignee: #{Task.where(assignee_id: nil).count}"
puts "  With due date: #{Task.where.not(due_at: nil).count}"
puts "  Without due date: #{Task.where(due_at: nil).count}"
puts "  With branch link: #{Task.where.not(branch_link: nil).count}"
puts "=" * 60
