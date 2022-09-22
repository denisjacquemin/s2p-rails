class AddUseEmailColumnToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :use_email_column, :boolean, default: true
  end
end
