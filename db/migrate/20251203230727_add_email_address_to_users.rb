class AddEmailAddressToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_address, :string, null: false
  end
end
