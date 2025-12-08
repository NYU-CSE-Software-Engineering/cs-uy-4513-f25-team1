class Task < ApplicationRecord
  belongs_to :project
  belongs_to :collaborator, foreign_key: :assignee, optional: true

  enum :status, {
    todo: "Todo",
    in_progress: "In Progress",
    in_review: "In Review",
    completed: "Completed"
  }

  enum :priority, {
    no_priority: "No Priority",
    low: "Low",
    medium: "Medium",
    high: "High",
    urgent: "Urgent"
  }

  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true

  before_validation :set_default_priority
  before_validation :set_status_based_on_assignee, on: :create

  validate :follows_WIPLimit, if: -> { status == "in_progress" }

  private

  def set_default_priority
    self.priority = :no_priority if priority.blank?
  end

  def set_status_based_on_assignee
    if status.blank?
      if assignee.nil?
        self.status = :todo
      else
        self.status = :in_progress
      end
    end
  end

  def follows_WIPLimit
    in_progress_count = project.tasks.where(status: "In Progress").where.not(id: id).count

    if in_progress_count >= project.wip_limit
      errors.add(:base, "WIP limit reached for In Progress")
    end
  end
end
