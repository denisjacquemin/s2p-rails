class AddDisplayEmailAddressToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :display_email_address, :boolean, default: true
  end
end
