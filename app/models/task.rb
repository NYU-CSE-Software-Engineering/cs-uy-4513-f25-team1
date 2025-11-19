class Task < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  enum :status, { backlog: 0, todo: 1, in_progress: 2, done: 3 }, default: :backlog

  validates :title, presence: true
  # Only checks tasks that are in progress follow the limit
  validate :follows_WIPLimit, if: -> { in_progress? }

  private

  def follows_WIPLimit
    in_progress_count = project.tasks.in_progress.where.not(id: id).count

    if in_progress_count >= project.wip_limit
      errors.add(:base, "WIP limit reached for In Progress")
    end
  end
end
