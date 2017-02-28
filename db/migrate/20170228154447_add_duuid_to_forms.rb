class AddDuuidToForms < ActiveRecord::Migration[5.0]
  def change
    add_column :forms, :duuid, :uuid
  end
end
