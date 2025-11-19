require 'rails_helper'

RSpec.describe Task, type: :model do
  before do
    @user = User.create!(email: "test@example.com", password: "password")
    @project = Project.create!(name: "Alpha", user: @user)
  end

  context "creating a task in project Alpha" do
    it "creates a task with valid inputs" do
      @task = Task.create!(title: "Implement WIP limit", status: :todo, project_id: @project[:id])
      expect(@task).to be_valid
      expect(@task.todo?).to be true
    end

    it "fails to create task with title" do
      @task = Task.new(title: "", status: :todo, project_id: @project[:id])
      expect(@task).to_not be_valid
    end

    it "defines the expected status enum" do
      expect(Task.statuses.keys).to contain_exactly("backlog", "todo", "in_progress", "done")
    end
  end
end
