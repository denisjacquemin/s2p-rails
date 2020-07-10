class PeriodGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :period_groups do |t|
      t.integer :group_id
      t.integer :period_id

      t.timestamps
    end
  end
end
