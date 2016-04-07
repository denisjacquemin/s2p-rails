class AddClassroomAndLevelToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :classroom, :string
    add_column :students, :level, :string
  end
end
