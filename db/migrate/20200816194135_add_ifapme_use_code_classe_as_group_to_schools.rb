class AddIfapmeUseCodeClasseAsGroupToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :ifapme_use_code_classe_as_group, :boolean, default: false
  end
end
