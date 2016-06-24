class AddRegistrationidToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :registration_id, :string
  end
end
