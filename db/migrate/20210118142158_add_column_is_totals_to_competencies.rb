class AddColumnIsTotalsToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :is_totals, :boolean, default: :false
  end
end
