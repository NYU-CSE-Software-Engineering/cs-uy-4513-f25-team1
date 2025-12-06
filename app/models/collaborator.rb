class Collaborator < ApplicationRecord
  belongs_to :project
  belongs_to :user

  ROLES = %w[manager developer].freeze
  validates :role, inclusion: { in: ROLES }

  scope :managers, -> { where(role: "manager") }
  scope :developers, -> { where(role: "developer") }
end
