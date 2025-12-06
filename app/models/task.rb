class Task < ApplicationRecord
  self.inheritance_column = :_type_disabled # Disable STI to allow 'type' as a regular column
  belongs_to :project
  belongs_to :user


  validates :title, presence: true
  validates :status, presence: true
end
