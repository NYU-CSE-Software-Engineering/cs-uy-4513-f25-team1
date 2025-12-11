require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:project) do
    Project.create!(
      name: 'Test Project',
      description: 'For task specs'
    )
  end

  let(:user) do
    User.create!(
      username: 'test_user',
      email_address: 'test@example.com',
      password_digest: BCrypt::Password.create('password123')
    )
  end

  let(:developer_collaborator) do
    Collaborator.create!(user: user, project: project, role: :developer)
  end

  let(:manager_collaborator) do
    manager_user = User.create!(
      username: 'manager_user',
      email_address: 'manager@example.com',
      password_digest: BCrypt::Password.create('password123')
    )
    Collaborator.create!(user: manager_user, project: project, role: :manager)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      task = Task.new(
        title: 'Implement WIP limit',
        description: 'A description of the task',
        status: :todo,
        project: project
      )

      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = Task.new(
        title: nil,
        description: 'A description',
        status: :todo,
        project: project
      )

      expect(task).not_to be_valid
      expect(task.errors[:title]).to be_present
    end

    it 'is invalid without a description' do
      task = Task.new(
        title: 'Some title',
        description: nil,
        status: :todo,
        project: project
      )

      expect(task).not_to be_valid
      expect(task.errors[:description]).to be_present
    end

    it 'is invalid without a project' do
      task = Task.new(
        title: 'Orphan task',
        description: 'A description',
        status: :todo
      )

      expect(task).not_to be_valid
      expect(task.errors[:project]).to be_present
    end

    it 'is valid without an assignee (assignee is optional)' do
      task = Task.new(
        title: 'Unassigned task',
        description: 'A description',
        status: :todo,
        project: project,
        assignee: nil
      )

      expect(task).to be_valid
    end

    it 'is valid with a developer assignee' do
      task = Task.new(
        title: 'Assigned task',
        description: 'A description',
        status: :in_progress,
        project: project,
        assignee: developer_collaborator
      )

      expect(task).to be_valid
    end

    it 'is invalid with a manager assignee' do
      task = Task.new(
        title: 'Manager assigned task',
        description: 'A description',
        status: :in_progress,
        project: project,
        assignee: manager_collaborator
      )

      expect(task).not_to be_valid
      expect(task.errors[:assignee]).to include("cannot be a manager")
    end
  end

  describe 'status enum' do
    it 'supports todo status' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :todo, project: project)
      expect(task.todo?).to be true
    end

    it 'supports in_progress status' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :in_progress, project: project)
      expect(task.in_progress?).to be true
    end

    it 'supports in_review status' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :in_review, project: project)
      expect(task.in_review?).to be true
    end

    it 'supports completed status' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :completed, project: project)
      expect(task.completed?).to be true
    end
  end

  describe 'priority enum' do
    it 'supports no_priority' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :todo, project: project, priority: :no_priority)
      expect(task.no_priority?).to be true
    end

    it 'supports low priority' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :todo, project: project, priority: :low)
      expect(task.low?).to be true
    end

    it 'supports medium priority' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :todo, project: project, priority: :medium)
      expect(task.medium?).to be true
    end

    it 'supports high priority' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :todo, project: project, priority: :high)
      expect(task.high?).to be true
    end

    it 'supports urgent priority' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :todo, project: project, priority: :urgent)
      expect(task.urgent?).to be true
    end
  end

  describe 'completed_at callback' do
    it 'sets completed_at when status changes to completed' do
      task = Task.create!(title: 'Test', description: 'Desc', status: :in_progress, project: project)
      expect(task.completed_at).to be_nil

      task.update!(status: :completed)

      expect(task.completed_at).not_to be_nil
    end

    it 'does not change completed_at if already set' do
      original_time = 1.day.ago
      task = Task.create!(title: 'Test', description: 'Desc', status: :completed, project: project, completed_at: original_time)

      expect(task.completed_at).to be_within(1.second).of(original_time)
    end
  end

  describe 'completed task immutability' do
    let!(:completed_task) do
      Task.create!(
        title: 'Completed Task',
        description: 'Done',
        status: :completed,
        project: project,
        completed_at: 1.day.ago
      )
    end

    it 'prevents modifications to completed tasks' do
      completed_task.title = 'New Title'
      expect(completed_task.save).to be false
      expect(completed_task.errors[:base]).to include("Completed tasks cannot be modified")
    end
  end
end
