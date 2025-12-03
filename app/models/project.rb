class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :collaborators
  has_many :users, through: :collaborators

  validates :name, presence: true

  def get_task_limit
    wip_limit
  end

  def count_tasks
    tasks.count
  end
end
