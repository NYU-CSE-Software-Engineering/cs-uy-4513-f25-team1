require "rails_helper"

RSpec.describe Task, type: :model do
  it "has a limit of 2 tasks" do
    project = Project.create!(name: "Alpha", wip_limit: 2)
    expect(project.get_task_limit).to eq(2)
    expect(project.count_tasks).to eq(0)
  end
end
