Given('a task titled {string} exists in project {string} with priority {string}') do |title, project_name, priority|
  project = Project.find_by!(name: project_name)
  # We need to handle the case where priority isn't implemented yet in the model
  # For now, we'll try to set it, but expect it might fail if the column doesn't exist
  task = project.tasks.create!(title: title, status: :todo)
  if task.respond_to?(:priority=)
    task.priority = priority.downcase
    task.save!
  end
end

When('I edit the task {string}') do |title|
  task = Task.find_by!(title: title)
  visit edit_project_task_path(task.project, task)
end

Then('I should see {string} within the task details') do |priority|
  # This assumes we'll display priority in a specific element or just on the page
  expect(page).to have_content(priority)
end
