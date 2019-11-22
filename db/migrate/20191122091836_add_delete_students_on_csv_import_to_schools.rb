class AddDeleteStudentsOnCsvImportToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :delete_students_on_csv_import, :boolean, default: false
  end
end
