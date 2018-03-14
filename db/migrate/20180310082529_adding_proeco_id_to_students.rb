class AddingProecoIdToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :proeco_id, :string
  end
end
