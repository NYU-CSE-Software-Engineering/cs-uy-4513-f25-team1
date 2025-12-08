class UpdateTasksSchema < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :tasks, :users if foreign_key_exists?(:tasks, :users)
    remove_index :tasks, :user_id if index_exists?(:tasks, :user_id)
    remove_column :tasks, :user_id, :integer if column_exists?(:tasks, :user_id)
    remove_column :tasks, :type, :string if column_exists?(:tasks, :type)

    add_column :tasks, :description, :string unless column_exists?(:tasks, :description)
    add_column :tasks, :due_at, :datetime unless column_exists?(:tasks, :due_at)
    add_column :tasks, :priority, :string, default: "No Priority" unless column_exists?(:tasks, :priority)
    add_column :tasks, :assignee, :integer unless column_exists?(:tasks, :assignee)
    add_column :tasks, :branch_link, :string unless column_exists?(:tasks, :branch_link)

    add_foreign_key :tasks, :collaborators, column: :assignee unless foreign_key_exists?(:tasks, column: :assignee)

    add_index :tasks, :assignee, name: "index_tasks_on_assignee" unless index_exists?(:tasks, :assignee)
    add_index :tasks, :status, name: "index_tasks_on_status" unless index_exists?(:tasks, :status)
    add_index :tasks, :priority, name: "index_tasks_on_priority" unless index_exists?(:tasks, :priority)
    add_index :tasks, :due_at, name: "index_tasks_on_due_at" unless index_exists?(:tasks, :due_at)
    add_index :tasks, [:project_id, :status], name: "index_tasks_on_project_id_and_status" unless index_exists?(:tasks, [:project_id, :status], name: "index_tasks_on_project_id_and_status")
  end
end
