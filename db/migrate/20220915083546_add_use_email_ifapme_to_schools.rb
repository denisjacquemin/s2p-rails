class AddUseEmailIfapmeToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :use_email_ifapme, :boolean, default: false
  end
end
