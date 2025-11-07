class Task < ApplicationRecord

  STATUS_OPTIONS = [ "To Do", "In Progress", "Done" ].freeze

  validates :title, presence: true
  validates :status, presence: true
end
