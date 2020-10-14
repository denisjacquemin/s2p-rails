class AddIfapmeFormateurToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :ifapme_formateur, :boolean, default: :false
  end
end
