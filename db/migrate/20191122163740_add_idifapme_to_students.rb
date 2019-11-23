class AddIdifapmeToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :idifapme, :string
  end
end
