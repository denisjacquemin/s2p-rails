class AddAcawebToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :acaweb, :boolean, default: false
  end
end
