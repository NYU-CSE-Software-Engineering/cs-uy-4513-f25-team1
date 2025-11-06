Given('a project named {string} exists with WIP limit {int}') do |project_name, limit|
  raise "FAIL: Implementation required for project setup with WIP limit"
end

Given('there are already {int} tasks in status {string}') do |count, status|
  raise "FAIL: Implementation required for creating existing tasks"
end

Given('I am on the {string} project board') do |project_name|
  raise "FAIL: Implementation required for navigating to project board"
end

When('I move {string} to {string}') do |task_name, status|
  raise "FAIL: Implementation required for moving a task"
end

Then('I should see {string}') do |message|
  raise "FAIL: Implementation required for checking message: #{message}"
end

Then('{string} should remain in {string}') do |task_name, status|
  raise "FAIL: Implementation required for checking task status"
end
