class AddStudentIdToRecipients < ActiveRecord::Migration[5.2]
  def change
    add_index :recipients, :student_id
  end
end
