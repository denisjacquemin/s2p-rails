class AddWinpageMatriculeToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :winpage_matricule, :string
  end
end
