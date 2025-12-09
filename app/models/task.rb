class Task < ApplicationRecord
  self.inheritance_column = :_type_disabled # Disable STI to allow 'type' as a regular column
  belongs_to :project
  belongs_to :user

  has_many_attached :media_files

  validates :title, presence: true
  validates :status, presence: true
  # Only checks tasks that are in progress follow the limit
  validate :follows_WIPLimit, if: -> { status == "In Progress" }
  validate :validate_media_files

  private

  MAX_MEDIA_FILES = 10
  MAX_FILE_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg image/png image/gif image/svg+xml image/webp
    application/pdf
    application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ].freeze

  def follows_WIPLimit
    in_progress_count = project.tasks.where(status: "In Progress").where.not(id: id).count

    if in_progress_count >= project.wip_limit
      errors.add(:base, "WIP limit reached for In Progress")
    end
  end

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
end
