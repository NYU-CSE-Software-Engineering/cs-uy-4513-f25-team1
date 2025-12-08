class AddDescriptionToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :description, :string unless column_exists?(:projects, :description)
  end
end
