class AddIsCityToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :iscity, :boolean, default: false
  end
end
