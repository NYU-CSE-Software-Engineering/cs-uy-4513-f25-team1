project = Project.first || Project.create!(name: "Test Project", key: "TEST", user_id: User.first.id)
user = User.first

puts "Testing Task creation with due_date..."

due_date = 1.week.from_now
task = project.tasks.create!(
  title: "Task with Due Date",
  description: "This task has a due date.",
  status: "todo",
  priority: "medium",
  user: user,
  due_date: due_date
)

if task.persisted? && task.due_date.present?
  puts "SUCCESS: Task created with due_date: #{task.due_date}"
else
  puts "FAILURE: Task could not be created or due_date is missing."
  puts task.errors.full_messages
end

puts "Verifying created_at..."
if task.created_at.present?
  puts "SUCCESS: Task has created_at: #{task.created_at}"
else
  puts "FAILURE: Task missing created_at."
end
