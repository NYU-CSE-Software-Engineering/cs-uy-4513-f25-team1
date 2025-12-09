class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :collaborators, dependent: :destroy
  has_many :projects, through: :collaborators

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
