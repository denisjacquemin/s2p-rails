class DropCompetencyGroups < ActiveRecord::Migration[5.2]
  def change
    drop_table :competency_groups
  end
end
