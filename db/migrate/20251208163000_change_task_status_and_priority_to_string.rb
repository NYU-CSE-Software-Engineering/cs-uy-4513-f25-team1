class ChangeTaskStatusAndPriorityToString < ActiveRecord::Migration[8.0]
  def change
    change_column :tasks, :status, :string unless column_exists?(:tasks, :status, :string)
    change_column :tasks, :priority, :string unless column_exists?(:tasks, :priority, :string)
  end
end
