class AddTypeToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :type, :string, default: ''
  end
end
