require "rails_helper"

RSpec.describe Task, type: :model do
  let(:user) do
    User.create!(
      username: "tester",
      email_address: "tester@example.com",
      password_digest: "password"
    )
  end

  let(:project_a) do
    Project.create!(
      name: "Project A",
      description: "First project"
    )
  end

  let(:project_b) do
    Project.create!(
      name: "Project B",
      description: "Second project"
    )
  end

  describe "project scoping" do
    let!(:task_a1) do
      Task.create!(
        title: "Task A1",
        status: "not started",
        project: project_a,
        user: user,
        type: "Feature"
      )
    end

    let!(:task_a2) do
      Task.create!(
        title: "Task A2",
        status: "in progress",
        project: project_a,
        user: user,
        type: "Bug"
      )
    end

    let!(:task_b1) do
      Task.create!(
        title: "Task B1",
        status: "not started",
        project: project_b,
        user: user,
        type: "Feature"
      )
    end

    it "returns only tasks that belong to a given project" do
      project_a_tasks = Task.where(project_id: project_a.id)

      expect(project_a_tasks).to include(task_a1, task_a2)
      expect(project_a_tasks).not_to include(task_b1)
    end
  end
end
