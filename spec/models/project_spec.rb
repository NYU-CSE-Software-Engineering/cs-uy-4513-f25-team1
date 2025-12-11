require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it 'is valid with name and description' do
      project = Project.new(
        name: 'Test Project',
        description: 'A test project description'
      )

      expect(project).to be_valid
    end

    it 'is invalid without a name' do
      project = Project.new(
        name: nil,
        description: 'A test project description'
      )

      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a description' do
      project = Project.new(
        name: 'Test Project',
        description: nil
      )

      expect(project).not_to be_valid
      expect(project.errors[:description]).to include("can't be blank")
    end

    it 'is invalid with an empty name' do
      project = Project.new(
        name: '',
        description: 'A test project description'
      )

      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with an empty description' do
      project = Project.new(
        name: 'Test Project',
        description: ''
      )

      expect(project).not_to be_valid
      expect(project.errors[:description]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many tasks' do
      association = described_class.reflect_on_association(:tasks)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many collaborators' do
      association = described_class.reflect_on_association(:collaborators)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many users through collaborators' do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:collaborators)
    end
  end

  describe 'dependent destroy' do
    let!(:project) { Project.create!(name: 'Test Project', description: 'Test description') }
    let!(:user) { User.create!(email_address: 'spec_project_user@example.com', username: 'testuser', password: 'SecurePassword123') }

    it 'destroys associated tasks when project is destroyed' do
      Task.create!(title: 'Test Task', description: 'Task description', status: :todo, project: project)

      expect { project.destroy }.to change(Task, :count).by(-1)
    end
  end

  describe '#count_tasks' do
    let!(:project) { Project.create!(name: 'Test Project', description: 'Test description') }

    it 'returns 0 when project has no tasks' do
      expect(project.count_tasks).to eq(0)
    end

    it 'returns the correct count of tasks' do
      Task.create!(title: 'Task 1', description: 'Description', status: :todo, project: project)
      Task.create!(title: 'Task 2', description: 'Description', status: :in_progress, project: project)
      Task.create!(title: 'Task 3', description: 'Description', status: :completed, project: project)

      expect(project.count_tasks).to eq(3)
    end

    it 'does not count tasks from other projects' do
      other_project = Project.create!(name: 'Other Project', description: 'Other description')
      Task.create!(title: 'Task 1', description: 'Description', status: :todo, project: project)
      Task.create!(title: 'Other Task', description: 'Description', status: :todo, project: other_project)

      expect(project.count_tasks).to eq(1)
    end
  end

  describe 'optional attributes' do
    it 'allows repo to be nil' do
      project = Project.new(
        name: 'Test Project',
        description: 'A test project description',
        repo: nil
      )

      expect(project).to be_valid
    end

    it 'accepts a valid repo URL' do
      project = Project.create!(
        name: 'Test Project',
        description: 'A test project description',
        repo: 'https://github.com/user/repo'
      )

      expect(project.repo).to eq('https://github.com/user/repo')
    end
  end
end
