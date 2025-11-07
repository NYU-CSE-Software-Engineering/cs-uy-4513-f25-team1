require "rails_helper"

RSpec.describe Task, type: :model do
  project = Project.create!(name: "Alpha", WIPLimit: 2)

  it "prevents creating more than 2 tasks in In Progress" do
    task1 = Task.create(title: "Existing Task 1", project: project, status: "In Progress")
    expect(task1).to be_valid

    task2 = Task.create(title: "Existing Task 2", project: project, status: "In Progress")
    expect(task2).to be_valid

    task3 = Task.create(title: "Pre-existing Task 3", project: project, status: "In Progress")
    expect(task3).to_not be_valid
  end
end
