class ConvertTaskStatusToInteger < ActiveRecord::Migration[8.0]
  STATUS_MAPPING = {
    "To Do" => 0,
    "Todo" => 0,
    "In Progress" => 1,
    "In Review" => 2,
    "Completed" => 3
  }.freeze

  def up
    # Add temporary integer column
    add_column :tasks, :status_int, :integer

    # Convert existing string values to integers
    Task.reset_column_information
    Task.find_each do |task|
      status_value = STATUS_MAPPING[task.read_attribute(:status)] || 0
      task.update_column(:status_int, status_value)
    end

    # Remove old string column and rename new column
    remove_column :tasks, :status
    rename_column :tasks, :status_int, :status

    # Add default value
    change_column_default :tasks, :status, 0
  end

  def down
    # Add temporary string column
    add_column :tasks, :status_str, :string

    # Convert integers back to strings
    reverse_mapping = { 0 => "To Do", 1 => "In Progress", 2 => "In Review", 3 => "Completed" }

    Task.reset_column_information
    Task.find_each do |task|
      status_value = reverse_mapping[task.read_attribute(:status)] || "To Do"
      task.update_column(:status_str, status_value)
    end

    # Remove integer column and rename string column
    remove_column :tasks, :status
    rename_column :tasks, :status_str, :status
  end
end
