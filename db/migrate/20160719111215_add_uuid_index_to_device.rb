class AddUuidIndexToDevice < ActiveRecord::Migration[5.0]
  def change
    add_index :devices, :uuid, unique: true
  end
end
