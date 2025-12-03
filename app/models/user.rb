class User < ApplicationRecord
  has_many :tasks
  has_many :comments
  has_many :collaborators
  has_many :projects, through: :collaborators
end
