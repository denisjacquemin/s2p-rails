class AddSielIdToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :siel_id, :string
  end
end
