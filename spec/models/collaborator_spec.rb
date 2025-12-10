require 'rails_helper'

RSpec.describe Collaborator, type: :model do
  let(:user) { User.create!(email_address: 'user@example.com', username: 'testuser', password: 'SecurePassword123') }
  let(:other_user) { User.create!(email_address: 'other@example.com', username: 'otheruser', password: 'SecurePassword123') }
  let(:project) { Project.create!(name: 'Test Project', description: 'Test description') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      collaborator = Collaborator.new(user: user, project: project, role: :manager)
      expect(collaborator).to be_valid
    end

    it 'requires a role' do
      collaborator = Collaborator.new(user: user, project: project, role: nil)
      expect(collaborator).not_to be_valid
      expect(collaborator.errors[:role]).to include("can't be blank")
    end

    describe 'uniqueness' do
      it 'prevents duplicate user on the same project' do
        Collaborator.create!(user: user, project: project, role: :manager)
        duplicate = Collaborator.new(user: user, project: project, role: :developer)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('is already a collaborator on this project')
      end

      it 'allows same user on different projects' do
        other_project = Project.create!(name: 'Other Project', description: 'Other description')
        Collaborator.create!(user: user, project: project, role: :manager)
        collaborator = Collaborator.new(user: user, project: other_project, role: :manager)

        expect(collaborator).to be_valid
      end

      it 'allows different users on the same project' do
        Collaborator.create!(user: user, project: project, role: :manager)
        collaborator = Collaborator.new(user: other_user, project: project, role: :developer)

        expect(collaborator).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to a project' do
      collaborator = Collaborator.new(user: user, project: project, role: :manager)
      expect(collaborator.project).to eq(project)
    end

    it 'belongs to a user' do
      collaborator = Collaborator.new(user: user, project: project, role: :manager)
      expect(collaborator.user).to eq(user)
    end
  end

  describe 'roles' do
    it 'supports manager role' do
      collaborator = Collaborator.create!(user: user, project: project, role: :manager)
      expect(collaborator.manager?).to be true
    end

    it 'supports developer role' do
      collaborator = Collaborator.create!(user: user, project: project, role: :developer)
      expect(collaborator.developer?).to be true
    end

    it 'supports invited role' do
      collaborator = Collaborator.create!(user: user, project: project, role: :invited)
      expect(collaborator.invited?).to be true
    end

    it 'can transition from invited to developer' do
      collaborator = Collaborator.create!(user: user, project: project, role: :invited)
      collaborator.developer!
      expect(collaborator.developer?).to be true
    end
  end

  describe 'contribution metrics' do
    let(:collaborator) { Collaborator.create!(user: user, project: project, role: :developer) }
    let(:other_collaborator) { Collaborator.create!(user: other_user, project: project, role: :developer) }

    before do
      # Create tasks for the collaborator
      Task.create!(title: 'Task 1', description: 'Description', status: :completed, project: project, assignee: collaborator)
      Task.create!(title: 'Task 2', description: 'Description', status: :in_progress, project: project, assignee: collaborator)
      Task.create!(title: 'Task 3', description: 'Description', status: :completed, project: project, assignee: collaborator)

      # Create tasks for other collaborator
      Task.create!(title: 'Other Task 1', description: 'Description', status: :todo, project: project, assignee: other_collaborator)
      Task.create!(title: 'Other Task 2', description: 'Description', status: :completed, project: project, assignee: other_collaborator)
    end

    describe '#task_count' do
      it 'returns the number of tasks assigned to the collaborator' do
        expect(collaborator.task_count).to eq(3)
      end
    end

    describe '#completed_task_count' do
      it 'returns the number of completed tasks by the collaborator' do
        expect(collaborator.completed_task_count).to eq(2)
      end
    end

    describe '#contribution_percentage' do
      it 'calculates the percentage of completed tasks relative to all project tasks' do
        # Total tasks in project: 5
        # Collaborator's completed tasks: 2
        # Contribution: (2 / 5) * 100 = 40.0%
        expect(collaborator.contribution_percentage).to eq(40.0)
      end

      it 'returns 0 when project has no tasks' do
        empty_project = Project.create!(name: 'Empty Project', description: 'Empty')
        empty_collaborator = Collaborator.create!(user: user, project: empty_project, role: :developer)

        expect(empty_collaborator.contribution_percentage).to eq(0)
      end

      it 'returns 0 when user has no completed tasks' do
        expect(other_collaborator.contribution_percentage).to eq(20.0) # 1 completed out of 5 total
      end
    end
  end
end
