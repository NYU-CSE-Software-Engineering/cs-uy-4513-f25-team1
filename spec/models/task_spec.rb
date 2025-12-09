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

  describe 'validations' do
    it 'is valid with valid attributes' do
      task = Task.new(
        title: 'Implement WIP limit',
        status: 'To Do',
        project: project,
        user: user
      )

      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = Task.new(
        title: nil,
        status: 'To Do',
        project: project,
        user: user
      )

      expect(task).not_to be_valid
      expect(task.errors[:title]).to be_present
    end

    it 'is invalid without a project' do
      task = Task.new(
        title: 'Orphan task',
        status: 'To Do',
        user: user
      )

      expect(task).not_to be_valid
      expect(task.errors[:project]).to be_present
    end

    it 'is invalid without a user' do
      task = Task.new(
        title: 'No user task',
        status: 'To Do',
        project: project
      )

      expect(task).not_to be_valid
      expect(task.errors[:user]).to be_present
    end
  end
end

