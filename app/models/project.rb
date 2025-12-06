class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :collaborators, dependent: :destroy
  has_many :users, through: :collaborators

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  before_validation :generate_key, on: :create

  private

  def generate_key
    return if key.present?

    base = name.parameterize.upcase.gsub(/[^A-Z]/, "")[0..3]
    self.key = loop do
      random_suffix = SecureRandom.hex(2).upcase
      candidate = "#{base}-#{random_suffix}"
      break candidate unless Project.exists?(key: candidate)
    end
  end

  def get_task_limit
    wip_limit
  end

  def count_tasks
    tasks.count
  end
end
