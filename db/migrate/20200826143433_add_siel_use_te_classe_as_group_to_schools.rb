class AddSielUseTeClasseAsGroupToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :siel_use_te_classe_as_group, :boolean, default: false
  end
end
