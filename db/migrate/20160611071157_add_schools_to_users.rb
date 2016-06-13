class AddSchoolsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :schools, :integer, array: true, default: []
  end
end
