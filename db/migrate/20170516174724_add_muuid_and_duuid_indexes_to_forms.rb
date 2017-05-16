class AddMuuidAndDuuidIndexesToForms < ActiveRecord::Migration[5.0]
  def change
    add_index :forms, :muuid
    add_index :forms, :duuid
  end
end
