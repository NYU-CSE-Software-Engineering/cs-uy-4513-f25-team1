require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'password')
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(password: 'password')
      expect(user).to be_invalid
    end

    it 'is invalid without a password' do
      user = User.new(email: 'test@example.com')
      expect(user).to be_invalid
    end
  end
end
