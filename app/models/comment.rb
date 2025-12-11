class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :collaborator

  validates :content, presence: true

  delegate :user, to: :collaborator

  def authored_by?(current_collaborator)
    collaborator_id == current_collaborator&.id
  end
end
