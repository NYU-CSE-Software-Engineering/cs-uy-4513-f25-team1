class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :collaborators
  has_many :users, through: :collaborators

  validates :name, presence: true
  validates :description, presence: true

  def count_tasks
    tasks.count
  end
end
