class ChangeRoleToIntegerInCollaborators < ActiveRecord::Migration[8.0]
  ROLE_MAPPING = {
    "manager" => 0,
    "owner" => 0,
    "developer" => 1,
    "editor" => 1,
    "invited" => 2
  }.freeze

  def up
    add_column :collaborators, :role_int, :integer

    Collaborator.reset_column_information
    Collaborator.find_each do |collaborator|
      role_value = ROLE_MAPPING[collaborator.read_attribute(:role)] || 0
      collaborator.update_column(:role_int, role_value)
    end

    remove_column :collaborators, :role
    rename_column :collaborators, :role_int, :role
    change_column_null :collaborators, :role, false
    change_column_default :collaborators, :role, 0
  end

  def down
    change_column_default :collaborators, :role, nil
    change_column_null :collaborators, :role, true

    add_column :collaborators, :role_str, :string

    Collaborator.reset_column_information
    Collaborator.find_each do |collaborator|
      role_name = ROLE_MAPPING.key(collaborator.read_attribute(:role)) || "manager"
      collaborator.update_column(:role_str, role_name)
    end

    remove_column :collaborators, :role
    rename_column :collaborators, :role_str, :role
  end
end
