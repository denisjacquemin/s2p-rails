class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.string :rating
      t.string :comment
      t.integer :student_id
      t.integer :school_id
      t.integer :competency_id
      t.integer :period_id

      t.timestamps
    end
  end
end
