class Task < ApplicationRecord
  self.inheritance_column = :_type_disabled # Disable STI to allow 'type' as a regular column

  belongs_to :project
  belongs_to :assignee, class_name: "Collaborator", optional: true

  has_many_attached :media_files

  enum :status, { todo: 0, in_progress: 1, in_review: 2, completed: 3 }
  enum :priority, { no_priority: 0, low: 1, medium: 2, high: 3, urgent: 4 }

  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validate :validate_media_files
  validate :assignee_cannot_be_manager
  validate :completed_task_cannot_be_modified, on: :update

  before_save :set_completed_at_timestamp

  private

  MAX_MEDIA_FILES = 10
  MAX_FILE_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg image/png image/gif image/svg+xml image/webp
    application/pdf
    application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ].freeze

  def validate_media_files
    return unless media_files.attached?

    if media_files.count > MAX_MEDIA_FILES
      errors.add(:media_files, "cannot exceed #{MAX_MEDIA_FILES} files")
      return
    end

    media_files.each do |file|
      if file.byte_size > MAX_FILE_SIZE
        errors.add(:media_files, "#{file.filename} exceeds the maximum file size of #{MAX_FILE_SIZE / 1.megabyte}MB")
      end

      unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
        errors.add(:media_files, "#{file.filename} has an invalid file type. Allowed types: images, PDFs, and common document formats")
      end
    end
  end

  def assignee_cannot_be_manager
    return unless assignee.present?

    if assignee.manager?
      errors.add(:assignee, "cannot be a manager")
    end
  end

  def completed_task_cannot_be_modified
    return unless completed_at_was.present?

    if changed? && !changes.keys.all? { |key| %w[updated_at].include?(key) }
      errors.add(:base, "Completed tasks cannot be modified")
    end
  end

  def set_completed_at_timestamp
    if status_changed? && completed? && completed_at.blank?
      self.completed_at = Time.current
    end
  end
end
