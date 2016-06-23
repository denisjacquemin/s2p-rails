class AddUuidToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :uuid, :string
  end
end
