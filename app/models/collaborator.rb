class Collaborator < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum :role, { manager: 0, developer: 1, invited: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id, message: "is already a collaborator on this project" }

  # Calculate contribution percentage (completed tasks / total tasks in project)
  def contribution_percentage
    total_tasks = project.tasks.count
    return 0 if total_tasks.zero?

    completed_tasks = project.tasks.where(user_id: user_id, status: "Completed").count
    ((completed_tasks.to_f / total_tasks) * 100).round(1)
  end

  # Count tasks by user in this project
  def task_count
    project.tasks.where(user_id: user_id).count
  end

  # Count completed tasks by user in this project
  def completed_task_count
    project.tasks.where(user_id: user_id, status: "Completed").count
  end
end
