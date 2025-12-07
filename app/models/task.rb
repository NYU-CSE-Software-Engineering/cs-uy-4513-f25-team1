class Task < ApplicationRecord
  self.inheritance_column = :_type_disabled # Disable STI to allow 'type' as a regular column
  belongs_to :project
  belongs_to :user
  has_many :checklist_items, dependent: :destroy
  has_many_attached :files
  has_many :comments, dependent: :destroy

  enum :status, { todo: 0, in_progress: 1, review: 2, done: 3 }, default: :todo
  enum :priority, { none: 0, low: 1, medium: 2, high: 3, urgent: 4 }, default: :none, prefix: true

  validates :title, presence: true
  validates :status, presence: true

  scope :ordered, -> { order(due_date: :asc, priority: :desc) }
end
