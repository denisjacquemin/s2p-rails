class AddShowSchoolNameAsFromToSchoolToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :show_school_name_as_from, :boolean, default: true
  end
end
