class RemoveWipLimitAndAddRepoToProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :wip_limit, :integer
    add_column :projects, :repo, :string
  end
end
