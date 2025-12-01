class AddKeyAndDescriptionToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :key, :string
    add_index :projects, :key
    add_column :projects, :description, :text
  end
end
