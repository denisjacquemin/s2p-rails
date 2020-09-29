class AddSielUseFaseImplantationToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :siel_use_fase_implantation, :boolean, default: false
  end
end
