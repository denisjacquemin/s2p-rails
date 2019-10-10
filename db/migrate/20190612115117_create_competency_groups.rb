class CreateCompetencyGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :competency_groups do |t|
      t.integer :group_id
      t.integer :competency_id

      t.timestamps
    end
  end
end
