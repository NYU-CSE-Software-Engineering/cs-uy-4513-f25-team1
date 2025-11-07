class AddWipLimitToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :WIPLimit, :integer
  end
end
