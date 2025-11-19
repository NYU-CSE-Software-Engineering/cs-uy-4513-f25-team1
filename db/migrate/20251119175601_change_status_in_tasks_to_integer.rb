class ChangeStatusInTasksToInteger < ActiveRecord::Migration[8.0]
  def up
    change_column :tasks, :status, :integer, default: 0
  end

  def down
    change_column :tasks, :status, :string
  end
end
