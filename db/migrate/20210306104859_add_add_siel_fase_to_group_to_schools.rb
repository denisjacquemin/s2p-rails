class AddAddSielFaseToGroupToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :add_siel_fase_to_group, :boolean, default: :false
  end
end
