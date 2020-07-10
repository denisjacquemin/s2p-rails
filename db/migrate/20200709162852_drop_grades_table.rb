class DropGradesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :grades
  end
end
