class CreateForms < ActiveRecord::Migration[5.0]
  def change
    create_table :forms do |t|
      t.uuid :muuid
      t.json :formdata

      t.timestamps
    end
  end
end
