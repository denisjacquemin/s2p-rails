class AddColumnPhonesCountToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :phones_count, :integer
  end
end
