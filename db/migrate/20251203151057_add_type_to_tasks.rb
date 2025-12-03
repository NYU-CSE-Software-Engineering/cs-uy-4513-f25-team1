class AddTypeToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :type, :string
  end
end
