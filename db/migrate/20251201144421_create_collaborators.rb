class CreateCollaborators < ActiveRecord::Migration[8.0]
  def change
    create_table :collaborators do |t|
      t.string :role

      t.timestamps
    end
  end
end
