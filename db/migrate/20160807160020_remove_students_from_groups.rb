class RemoveStudentsFromGroups < ActiveRecord::Migration[5.0]
  def up
    remove_column :groups, :students
  end

  def down
    add_column :groups, :students, :integer, array: true, default: []
  end

end
