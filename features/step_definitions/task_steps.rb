Given("a project named {string} exists") do |project_name|
  Project.create!(name: project_name)
end

Given("I am on the {string} project's tasks page") do |project_name|
  project = Project.find_by!(name: project_name)
  visit project_tasks_path(project)
end

FIELD_ID_MAP = {
  "Priority" => "task_priority",
  "Assignee" => "task_assignee_id",
  "Branch Link" => "task_branch_link",
  "Due Date" => "task_due_at"
}.freeze

When("I fill in {string} with {string}") do |field_name, value|
  # Handle "(optional)" suffix in field names
  clean_field = field_name.gsub(/\s*\(optional\)\s*$/, '').strip
  field_id = FIELD_ID_MAP[clean_field]

  if field_id
    fill_in field_id, with: value
  else
    fill_in field_name, with: value
  end
end

When("I select {string} from {string}") do |option, field_name|
  # Handle "(optional)" suffix in field names
  clean_field = field_name.gsub(/\s*\(optional\)\s*$/, '').strip
  field_id = FIELD_ID_MAP[clean_field]

  if field_id
    select option, from: field_id
  else
    select option, from: field_name
  end
end


Then("I should see the task in the list for project {string}") do |project_name|
  project = Project.find_by!(name: project_name)
  expect(page).to have_current_path(project_tasks_path(project))
end

When("I leave {string} blank") do |field_name|
  fill_in field_name, with: ""
end
