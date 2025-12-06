class RemoveWipLimitFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :wip_limit, :integer
  end
end
