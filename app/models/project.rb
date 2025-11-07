class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  def get_task_limit
    wip_limit
  end

  def count_tasks
    tasks.count
  end
end
