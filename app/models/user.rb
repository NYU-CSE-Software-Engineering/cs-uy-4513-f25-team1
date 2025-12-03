class User < ApplicationRecord
  has_secure_password # keyword that confirms password, requires password to be renamed to password_digest and requires bcrypt gem

  validates :email, presence: true, uniqueness: true, format: {
    with: /\A[^@\s]+@[^@\s]+\z/, # Regex for valid looking email
    message: "must be a valid email address"
  }

  validates :username, presence: true, length: { minimum: 3, maximum: 20 }

  validates :password, presence: true, length: { minimum: 6 }, confirmation: true
  validates :password_confirmation, presence: true
end
