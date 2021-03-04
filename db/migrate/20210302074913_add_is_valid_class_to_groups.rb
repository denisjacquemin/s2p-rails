class AddIsValidClassToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :is_valid_class, :boolean, default: true
  end
end
