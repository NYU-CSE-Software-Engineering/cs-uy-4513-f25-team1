require 'rails_helper'

RSpec.describe Task, type: :model do
  before do
    @user = User.create!(email: "test@example.com", password: "password")
    @project = Project.create!(name: "Alpha", user: @user)
  end

  describe "enums" do
    it "defines the expected status enum" do
      expect(Task.statuses.keys).to contain_exactly("backlog", "todo", "in_progress", "done")
    end

    it "defines the expected priority enum" do
      expect(Task.priorities.keys).to contain_exactly("low", "medium", "high", "urgent")
    end
  end

  describe "defaults" do
    it "defaults to backlog status" do
      task = Task.new
      expect(task.status).to eq("backlog")
    end

    it "defaults to low priority" do
      task = Task.new
      expect(task.priority).to eq("low")
    end
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
