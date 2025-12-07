class CreateChecklistItems < ActiveRecord::Migration[8.0]
  def change
    create_table :checklist_items do |t|
      t.string :content
      t.boolean :completed
      t.references :task, null: false, foreign_key: true

      t.timestamps
    end
  end
end
