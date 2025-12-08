class AddWipLimitToProjectsIfMissing < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :wip_limit, :integer unless column_exists?(:projects, :wip_limit)
  end
end
