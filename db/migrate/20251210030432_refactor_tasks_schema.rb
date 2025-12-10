class RefactorTasksSchema < ActiveRecord::Migration[8.0]
  def up
    # Remove existing foreign key on user_id (references users)
    remove_foreign_key :tasks, :users

    # Rename user_id to assignee_id
    rename_column :tasks, :user_id, :assignee_id

    # Make assignee_id nullable (assignee is optional)
    change_column_null :tasks, :assignee_id, true

    # Add new foreign key to collaborators table
    add_foreign_key :tasks, :collaborators, column: :assignee_id

    # Add new columns
    add_column :tasks, :description, :string, null: false, default: ""
    add_column :tasks, :branch_link, :string
    add_column :tasks, :priority, :integer
    add_column :tasks, :due_at, :datetime
    add_column :tasks, :completed_at, :datetime

    # Remove the default after adding the column (existing records get empty string)
    change_column_default :tasks, :description, from: "", to: nil
  end

  def down
    # Remove new columns
    remove_column :tasks, :completed_at
    remove_column :tasks, :due_at
    remove_column :tasks, :priority
    remove_column :tasks, :branch_link
    remove_column :tasks, :description

    # Remove foreign key to collaborators
    remove_foreign_key :tasks, :collaborators

    # Make assignee_id not nullable
    change_column_null :tasks, :assignee_id, false

    # Rename assignee_id back to user_id
    rename_column :tasks, :assignee_id, :user_id

    # Add back foreign key to users
    add_foreign_key :tasks, :users
  end
end
