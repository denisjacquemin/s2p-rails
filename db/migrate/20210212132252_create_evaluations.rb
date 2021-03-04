class CreateEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluations do |t|
      t.integer :group_id
      t.integer :competency_id
      t.integer :period_id
      t.string :description
      t.string :weight
      t.integer :school_id

      t.timestamps
    end
  end
end
