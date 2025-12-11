class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :collaborators, dependent: :destroy
  has_many :projects, through: :collaborators
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
