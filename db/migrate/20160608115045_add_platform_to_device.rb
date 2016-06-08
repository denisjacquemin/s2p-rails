class AddPlatformToDevice < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :platform, :string
  end
end
