class AddCompetencyIdToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :competency_id, :integer
  end
end
