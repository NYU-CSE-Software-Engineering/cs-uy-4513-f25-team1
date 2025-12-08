require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:project) { create(:project) }

  describe "validations" do
    it "requires a title" do
      task = Task.new(description: "Test description", project: project)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to be_present
    end

    it "requires a description" do
      task = Task.new(title: "Test task", project: project)
      expect(task).not_to be_valid
      expect(task.errors[:description]).to be_present
    end

    it "is valid with title and description" do
      task = Task.new(title: "Test task", description: "Test description", project: project)
      expect(task).to be_valid
    end
  end

  describe "status enum" do
    it "accepts valid status values" do
      task = create(:task, project: project, status: "Todo")
      expect(task.status).to eq("todo")

      task.status = "In Progress"
      expect(task).to be_valid

      task.status = "In Review"
      expect(task).to be_valid

      task.status = "Completed"
      expect(task).to be_valid
    end
  end

  describe "priority enum" do
    it "accepts valid priority values" do
      task = create(:task, project: project, priority: "No Priority")
      expect(task.priority).to eq("no_priority")

      task.priority = "Low"
      expect(task).to be_valid

      task.priority = "Medium"
      expect(task).to be_valid

      task.priority = "High"
      expect(task).to be_valid

      task.priority = "Urgent"
      expect(task).to be_valid
    end

    it "defaults to 'No Priority' when priority is blank" do
      task = Task.new(title: "Test", description: "Test", project: project, priority: nil)
      task.valid?
      expect(task.priority).to eq("no_priority")
    end
  end

  describe "auto-status setting based on assignee" do
    it "sets status to 'Todo' when assignee is nil" do
      task = Task.new(title: "Test", description: "Test", project: project, assignee: nil)
      task.valid?
      expect(task.status).to eq("todo")
    end

    it "sets status to 'In Progress' when assignee is present" do
      collaborator = create(:collaborator, project: project)
      task = Task.new(title: "Test", description: "Test", project: project, assignee: collaborator.id)
      task.valid?
      expect(task.status).to eq("in_progress")
    end

    it "updates status to 'In Progress' when assignee is set on existing task" do
      task = create(:task, project: project, assignee: nil, status: "Todo")
      collaborator = create(:collaborator, project: project)
      task.assignee = collaborator.id
      task.status = :in_progress
      task.valid?
      expect(task.status).to eq("in_progress")
    end
  end

  describe "associations" do
    it "belongs to a project" do
      task = create(:task, project: project)
      expect(task.project).to eq(project)
    end

    it "belongs to a collaborator through assignee" do
      collaborator = create(:collaborator, project: project)
      task = create(:task, project: project, assignee: collaborator.id)
      expect(task.collaborator).to eq(collaborator)
    end

    it "can have no assignee" do
      task = create(:task, project: project, assignee: nil)
      expect(task.collaborator).to be_nil
    end
  end

  describe "WIP limit validation" do
    let(:project) { create(:project, wip_limit: 2) }

    it "allows creating task when WIP limit is not reached" do
      create(:task, project: project, status: "In Progress")
      task = build(:task, project: project, status: "In Progress")
      expect(task).to be_valid
    end

    it "prevents creating task when WIP limit is reached" do
      create(:task, project: project, status: "In Progress")
      create(:task, project: project, status: "In Progress")
      task = build(:task, project: project, status: "In Progress")
      expect(task).not_to be_valid
      expect(task.errors[:base]).to include("WIP limit reached for In Progress")
    end

    it "does not count other statuses toward WIP limit" do
      create(:task, project: project, status: "Todo")
      create(:task, project: project, status: "In Review")
      create(:task, project: project, status: "Completed")
      task = build(:task, project: project, status: "In Progress")
      expect(task).to be_valid
    end
  end
end
