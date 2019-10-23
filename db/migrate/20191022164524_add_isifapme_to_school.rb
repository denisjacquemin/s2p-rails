class AddIsifapmeToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :is_ifapme, :boolean, default: false
  end
end
