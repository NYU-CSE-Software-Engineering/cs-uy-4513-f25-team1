class Task < ApplicationRecord
  self.inheritance_column = :_type_disabled # Disable STI to allow 'type' as a regular column
  belongs_to :project
  belongs_to :user, optional: true
  has_many :comments, dependent: :destroy
  has_many_attached :attachments

  enum :status, { todo: 0, in_progress: 1, done: 2 }, default: :todo
  enum :priority, { no_priority: 0, low: 1, medium: 2, high: 3, urgent: 4 }, default: :no_priority

  validates :title, presence: true
  validates :status, presence: true
  # Only checks tasks that are in progress follow the limit
  validate :follows_WIPLimit, if: -> { in_progress? }

  private

  def follows_WIPLimit
    in_progress_count = project.tasks.where(status: :in_progress).where.not(id: id).count

    if in_progress_count >= project.wip_limit
      errors.add(:base, "WIP limit reached for In Progress")
    end
  end
end
