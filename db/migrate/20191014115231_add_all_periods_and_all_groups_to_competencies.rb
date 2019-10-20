class AddAllPeriodsAndAllGroupsToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :all_periods, :boolean, default: true
    add_column :competencies, :all_groups, :boolean, default: true
  end
end
