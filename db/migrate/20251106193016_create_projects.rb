class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :wip_limit, default: 2
      t.timestamps
    end
  end
end
