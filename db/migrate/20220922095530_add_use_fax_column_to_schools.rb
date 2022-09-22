class AddUseFaxColumnToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :use_fax_column, :boolean, default: false
  end
end
