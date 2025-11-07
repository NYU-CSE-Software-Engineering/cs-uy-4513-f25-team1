class Task < ApplicationRecord
  belongs_to :project
  STATUS_OPTIONS = [ "To Do", "In Progress", "Done" ].freeze

  validates :title, presence: true
  validates :status, presence: true
end
