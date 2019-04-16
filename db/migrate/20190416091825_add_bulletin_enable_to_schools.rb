class AddBulletinEnableToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :bulletin_enable, :boolean, default: :false
  end
end
