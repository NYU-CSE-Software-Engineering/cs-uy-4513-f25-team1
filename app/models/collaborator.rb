class Collaborator < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum :role, { manager: 0, developer: 1, invited: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id, message: "is already a collaborator on this project" }
end
