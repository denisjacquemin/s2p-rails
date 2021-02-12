class CreateAverages < ActiveRecord::Migration[5.2]
  def change
    create_table :averages do |t|
      t.integer :student_id
      t.integer :period_id
      t.integer :competency_id
      t.integer :group_id
      t.integer :school_id
      t.string :value

      t.timestamps
    end
  end
end
