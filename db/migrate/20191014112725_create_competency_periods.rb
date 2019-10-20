class CreateCompetencyPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :competency_periods do |t|
      t.integer :competency_id
      t.integer :period_id

      t.timestamps
    end
  end
end
