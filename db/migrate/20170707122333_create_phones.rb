class CreatePhones < ActiveRecord::Migration[5.0]
  def change
    create_table :phones do |t|
      t.string :owner_name
      t.string :number
      t.integer :student_id

      t.timestamps
    end
  end
end
