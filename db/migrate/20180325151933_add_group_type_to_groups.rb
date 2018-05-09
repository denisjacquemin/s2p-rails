class AddGroupTypeToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :group_type, :string, default: ''
  end
end
