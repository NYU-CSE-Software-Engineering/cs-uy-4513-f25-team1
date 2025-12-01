class Task < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :status, presence: true
  # Only checks tasks that are in progress follow the limit
  validate :follows_WIPLimit, if: -> { status == "In Progress" }

  private

  def follows_WIPLimit
    in_progress_count = project.tasks.where(status: "In Progress").where.not(id: id).count

    if in_progress_count >= project.wip_limit
      errors.add(:base, "WIP limit reached for In Progress")
    end
  end
end
