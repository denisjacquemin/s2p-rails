class CreateCompetencies < ActiveRecord::Migration[5.2]
  def change
    create_table :competencies do |t|
      t.string :name
      t.integer :school_id
      t.integer :level
      t.integer :order
      t.timestamps
    end
  end
end
