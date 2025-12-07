class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :collaborators, dependent: :destroy
  has_many :projects, through: :collaborators

  validates :email_address, presence: true, uniqueness: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def manager_projects
    Project.joins(:collaborators).where(collaborators: { user_id: id, role: "manager" }).order(updated_at: :desc)
  end

  def developer_projects
    Project.joins(:collaborators).where(collaborators: { user_id: id, role: "developer" }).order(updated_at: :desc)
  end

  def role_for(project)
    collaborators.find_by(project: project)&.role
  end
end
