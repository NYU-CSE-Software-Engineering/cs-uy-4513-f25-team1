require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        email_address: 'test@example.com',
        username: 'testuser',
        password: 'SecurePassword123'
      )

      expect(user).to be_valid
    end

    it 'is invalid without an email address' do
      user = User.new(
        email_address: nil,
        username: 'testuser',
        password: 'SecurePassword123'
      )

      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to be_present
    end

    it 'is invalid with a malformed email address' do
      user = User.new(
        email_address: 'not-an-email',
        username: 'testuser',
        password: 'SecurePassword123'
      )

      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to be_present
    end

    it 'is invalid without a password' do
      user = User.new(
        email_address: 'test@example.com',
        username: 'testuser',
        password: nil
      )

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it 'is invalid with a password under 8 characters' do
      user = User.new(
        email_address: 'test@example.com',
        username: 'testuser',
        password: 'short'
      )

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it 'is valid with a password of exactly 8 characters' do
      user = User.new(
        email_address: 'test@example.com',
        username: 'testuser',
        password: '12345678'
      )

      expect(user).to be_valid
    end
  end

  describe 'email normalization' do
    it 'strips whitespace from email' do
      user = User.create!(
        email_address: '  test@example.com  ',
        username: 'testuser',
        password: 'SecurePassword123'
      )

      expect(user.email_address).to eq('test@example.com')
    end

    it 'lowercases email' do
      user = User.create!(
        email_address: 'TEST@EXAMPLE.COM',
        username: 'testuser',
        password: 'SecurePassword123'
      )

      expect(user.email_address).to eq('test@example.com')
    end
  end

  describe 'associations' do
    it 'has many sessions' do
      association = described_class.reflect_on_association(:sessions)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many collaborators' do
      association = described_class.reflect_on_association(:collaborators)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many projects through collaborators' do
      association = described_class.reflect_on_association(:projects)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:collaborators)
    end
  end

  describe 'dependent destroy' do
    let!(:user) { User.create!(email_address: 'test@example.com', username: 'testuser', password: 'SecurePassword123') }
    let!(:project) { Project.create!(name: 'Test Project', description: 'Test description') }

    it 'destroys associated sessions when user is destroyed' do
      Session.create!(user: user)

      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it 'destroys associated collaborators when user is destroyed' do
      Collaborator.create!(user: user, project: project, role: :developer)

      expect { user.destroy }.to change(Collaborator, :count).by(-1)
    end
  end
end
