class CreateQuotations < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations do |t|
      t.integer :evaluation_id
      t.integer :school_id
      t.integer :student_id
      t.boolean :averageable, default: true
      t.string :value

      t.timestamps
    end
  end
end
